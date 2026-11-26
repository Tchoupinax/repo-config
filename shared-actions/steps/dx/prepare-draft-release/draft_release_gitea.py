#!/usr/bin/env python3
"""Gitea-native replacement for release-drafter.

release-drafter relies on GitHub's GraphQL API to find commits between refs.
Gitea exposes no GraphQL endpoint, so that step returns "404 page not found".
This script reproduces the needed behaviour using Gitea's REST API only:

  - find the last published release (base) and any existing draft (to update)
  - list merged pull requests reachable from base..head via the compare endpoint
  - categorize them and resolve the next version from the config labels
  - create or update the draft release

It reads the same .github/release-drafter.yml config as release-drafter.
"""

import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

try:
    import yaml
except ImportError:
    sys.exit("PyYAML is required (pip install pyyaml)")


def env(name, default=None, required=False):
    value = os.environ.get(name, default)
    if required and not value:
        sys.exit(f"Missing required environment variable: {name}")
    return value


HOST = env("GITEA_HOST", required=True).rstrip("/")
if not HOST.startswith("http"):
    HOST = "https://" + HOST
API = f"{HOST}/api/v1"
TOKEN = env("GITEA_TOKEN", required=True)
REPO = env("GITHUB_REPOSITORY", required=True)  # owner/repo
OWNER, NAME = REPO.split("/", 1)
HEAD = env("GITHUB_REF_NAME", "master")
CONFIG_PATH = env("CONFIG_PATH", ".github/release-drafter.yml")


def request(method, path, body=None):
    url = path if path.startswith("http") else f"{API}{path}"
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"token {TOKEN}")
    req.add_header("Accept", "application/json")
    if data is not None:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read()
            return json.loads(raw) if raw else None
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode(errors="replace")
        raise SystemExit(f"{method} {url} -> {exc.code}: {detail}")


# --- config ----------------------------------------------------------------

with open(CONFIG_PATH, "r", encoding="utf-8") as handle:
    config = yaml.safe_load(handle)

categories = config.get("categories", []) or []
change_template = config.get("change-template", "* $TITLE (#$NUMBER) @$AUTHOR")
title_escapes = config.get("change-title-escapes", "")
name_template = config.get("name-template", "v$RESOLVED_VERSION")
tag_template = config.get("tag-template", "v$RESOLVED_VERSION")
body_template = config.get("template", "$CHANGES")
no_changes = config.get("no-changes-template", "* No changes")

resolver = config.get("version-resolver", {}) or {}


def resolver_labels(kind):
    section = resolver.get(kind, {}) or {}
    return set(section.get("labels", []) or [])


MAJOR_LABELS = resolver_labels("major")
MINOR_LABELS = resolver_labels("minor")
PATCH_LABELS = resolver_labels("patch")
DEFAULT_BUMP = resolver.get("default", "patch")


def category_labels(category):
    labels = category.get("labels")
    if labels is None and "label" in category:
        labels = [category["label"]]
    return set(labels or [])


# --- releases --------------------------------------------------------------

releases = request("GET", f"/repos/{OWNER}/{NAME}/releases?limit=50") or []

draft_release = next((r for r in releases if r.get("draft")), None)
published = [r for r in releases if not r.get("draft") and not r.get("prerelease")]


def parse_version(tag):
    match = re.search(r"(\d+)\.(\d+)\.(\d+)", tag or "")
    if not match:
        return None
    return tuple(int(part) for part in match.groups())


def version_sort_key(release):
    return parse_version(release.get("tag_name")) or (0, 0, 0)


last_release = max(published, key=version_sort_key) if published else None
base_tag = last_release.get("tag_name") if last_release else None
last_version = parse_version(base_tag) if base_tag else (0, 0, 0)

print(f"Head: {HEAD}")
print(f"Last published release: {base_tag or '(none)'}")

# --- commits in range ------------------------------------------------------

commit_shas = set()
if base_tag:
    base_enc = urllib.parse.quote(base_tag, safe="")
    head_enc = urllib.parse.quote(HEAD, safe="")
    compare = request(
        "GET", f"/repos/{OWNER}/{NAME}/compare/{base_enc}...{head_enc}"
    )
    for commit in (compare or {}).get("commits", []) or []:
        commit_shas.add(commit.get("sha"))
    print(f"Commits between {base_tag} and {HEAD}: {len(commit_shas)}")

# --- merged pull requests --------------------------------------------------

pulls = []
page = 1
while True:
    batch = request(
        "GET",
        f"/repos/{OWNER}/{NAME}/pulls?state=closed&sort=recentupdate&limit=50&page={page}",
    )
    if not batch:
        break
    for pr in batch:
        if not pr.get("merged_at"):
            continue
        if pr.get("base", {}).get("ref") != HEAD:
            continue
        # When we have a base release, only keep PRs whose merge commit is in range.
        if commit_shas and pr.get("merge_commit_sha") not in commit_shas:
            continue
        pulls.append(pr)
    if len(batch) < 50 or page >= 20:
        break
    page += 1

print(f"Pull requests included: {len(pulls)}")

# --- categorize + version --------------------------------------------------


def resolve_bump(all_labels):
    if all_labels & MAJOR_LABELS:
        return "major"
    if all_labels & MINOR_LABELS:
        return "minor"
    if all_labels & PATCH_LABELS:
        return "patch"
    return DEFAULT_BUMP


all_labels = set()
for pr in pulls:
    for label in pr.get("labels", []) or []:
        all_labels.add(label.get("name"))

bump = resolve_bump(all_labels)
major, minor, patch = last_version
if bump == "major":
    next_version = (major + 1, 0, 0)
elif bump == "minor":
    next_version = (major, minor + 1, 0)
else:
    next_version = (major, minor, patch + 1)

resolved_version = ".".join(str(part) for part in next_version)
print(f"Version bump: {bump} -> {resolved_version}")


def escape_title(title):
    if not title_escapes:
        return title
    chars = set(title_escapes) - {"\\"}
    out = []
    for ch in title:
        if ch in chars:
            out.append("\\" + ch)
        else:
            out.append(ch)
    return "".join(out)


def render_change(pr):
    author = pr.get("user", {}).get("login", "")
    return (
        change_template.replace("$TITLE", escape_title(pr.get("title", "")))
        .replace("$NUMBER", str(pr.get("number", "")))
        .replace("$AUTHOR", author)
        .replace("$BODY", pr.get("body") or "")
        .replace("$URL", pr.get("html_url", ""))
    )


used = set()
sections = []
for category in categories:
    labels = category_labels(category)
    matched = [
        pr
        for pr in pulls
        if pr.get("number") not in used
        and labels & {label.get("name") for label in pr.get("labels", []) or []}
    ]
    if not matched:
        continue
    for pr in matched:
        used.add(pr.get("number"))
    lines = "\n".join(render_change(pr) for pr in matched)
    sections.append(f"## {category['title']}\n\n{lines}")

uncategorized = [pr for pr in pulls if pr.get("number") not in used]
if uncategorized:
    lines = "\n".join(render_change(pr) for pr in uncategorized)
    sections.append(lines)

changes = "\n\n".join(sections) if sections else no_changes

body = (
    body_template.replace("$CHANGES", changes)
    .replace("$RESOLVED_VERSION", resolved_version)
    .replace("$PREVIOUS_TAG", base_tag or "")
)

release_name = name_template.replace("$RESOLVED_VERSION", resolved_version)
release_tag = tag_template.replace("$RESOLVED_VERSION", resolved_version)

# --- upsert draft ----------------------------------------------------------

payload = {
    "tag_name": release_tag,
    "name": release_name,
    "body": body,
    "draft": True,
    "prerelease": False,
}

if draft_release:
    payload["target_commitish"] = HEAD
    request(
        "PATCH",
        f"/repos/{OWNER}/{NAME}/releases/{draft_release['id']}",
        payload,
    )
    print(f"Updated draft release {draft_release['id']} -> {release_name}")
else:
    payload["target_commitish"] = HEAD
    created = request("POST", f"/repos/{OWNER}/{NAME}/releases", payload)
    print(f"Created draft release {created.get('id')} -> {release_name}")

# --- outputs ---------------------------------------------------------------

output_file = os.environ.get("GITHUB_OUTPUT")
if output_file:
    with open(output_file, "a", encoding="utf-8") as handle:
        handle.write(f"resolved-version={resolved_version}\n")
        handle.write(f"tag-name={release_tag}\n")
        handle.write(f"bump={bump}\n")
        handle.write(f"labels={','.join(sorted(l for l in all_labels if l))}\n")
