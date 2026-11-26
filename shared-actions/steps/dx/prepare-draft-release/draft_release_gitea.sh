#!/usr/bin/env bash
# Gitea-native replacement for release-drafter.
#
# release-drafter relies on GitHub's GraphQL API to find commits between refs.
# Gitea exposes no GraphQL endpoint, so that step returns "404 page not found".
# This script reproduces the needed behaviour using Gitea's REST API only:
#
#   - find the last published release (base) and any existing draft (to update)
#   - list merged pull requests reachable from base..head via the compare endpoint
#   - categorize them and resolve the next version from the config labels
#   - create or update the draft release
#
# It reads the same .github/release-drafter.yml config as release-drafter, in
# both the legacy (labels, version-resolver.*.labels) and the current
# (when, semver-increment) formats.
#
# Requires bash, curl and jq. mikefarah/yq is downloaded when not available.

set -euo pipefail

: "${GITEA_HOST:?Missing required environment variable: GITEA_HOST}"
: "${GITEA_TOKEN:?Missing required environment variable: GITEA_TOKEN}"
: "${GITHUB_REPOSITORY:?Missing required environment variable: GITHUB_REPOSITORY}"
HEAD="${GITHUB_REF_NAME:-master}"
CONFIG_PATH="${CONFIG_PATH:-.github/release-drafter.yml}"

YQ_VERSION="v4.54.3"
YQ_SHA256_amd64="129534601871538efe0ba4c5e62a34fb1d5f469bcb975c4fddeb467d82974973"
YQ_SHA256_arm64="89f69310b61b68d1245065a1241d1fc843f7a36cd6103ffd77ad987613bd1b67"

command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

host="${GITEA_HOST%/}"
[[ "$host" == http* ]] || host="https://${host}"
API="${host}/api/v1/repos/${GITHUB_REPOSITORY}"

# JSON goes through files rather than --argjson: a single argument is capped
# at 128KiB on Linux and PR bodies easily exceed it.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

api() {
  local method=$1 path=$2 body=${3:-} response status
  local args=(-sS -X "$method" -w '\n%{http_code}'
    -H "Authorization: token ${GITEA_TOKEN}" -H "Accept: application/json")
  if [[ -n "$body" ]]; then
    args+=(-H "Content-Type: application/json" --data-binary @-)
  fi
  response=$(printf '%s' "$body" | curl "${args[@]}" "${API}${path}")
  status=${response##*$'\n'}
  response=${response%$'\n'*}
  if [[ "$status" != 2* ]]; then
    echo "${method} ${API}${path} -> ${status}: ${response}" >&2
    exit 1
  fi
  printf '%s' "$response"
}

uri() { jq -rn --arg value "$1" '$value | @uri'; }

ensure_yq() {
  if command -v yq >/dev/null && yq --version 2>&1 | grep -q mikefarah; then
    YQ=yq
    return
  fi
  local arch sha
  case "$(uname -m)" in
    x86_64 | amd64) arch=amd64 sha=$YQ_SHA256_amd64 ;;
    aarch64 | arm64) arch=arm64 sha=$YQ_SHA256_arm64 ;;
    *) echo "Unsupported architecture for yq: $(uname -m)" >&2; exit 1 ;;
  esac
  YQ="${tmp}/yq"
  curl -fsSL -o "$YQ" "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${arch}"
  echo "${sha}  ${YQ}" | sha256sum -c --quiet -
  chmod +x "$YQ"
}

# --- config ----------------------------------------------------------------

ensure_yq
"$YQ" -o=json '.' "$CONFIG_PATH" >"${tmp}/config.json"

# --- releases --------------------------------------------------------------

api GET "/releases?limit=50" >"${tmp}/releases.json"

draft_id=$(jq -r 'map(select(.draft)) | first | .id // empty' "${tmp}/releases.json")
base_tag=$(jq -r '
  def version: (.tag_name // "" | capture("(?<a>\\d+)\\.(?<b>\\d+)\\.(?<c>\\d+)") | [.a, .b, .c] | map(tonumber)) // [0, 0, 0];
  map(select((.draft | not) and (.prerelease | not))) | max_by(version) | .tag_name // empty
' "${tmp}/releases.json")

echo "Head: ${HEAD}"
echo "Last published release: ${base_tag:-(none)}"

# --- commits in range ------------------------------------------------------

echo "null" >"${tmp}/commits.json"
if [[ -n "$base_tag" ]]; then
  api GET "/compare/$(uri "$base_tag")...$(uri "$HEAD")" | jq -c '[.commits[]?.sha]' >"${tmp}/commits.json"
  echo "Commits between ${base_tag} and ${HEAD}: $(jq length "${tmp}/commits.json")"
fi

# --- merged pull requests --------------------------------------------------

: >"${tmp}/pulls.jsonl"
for page in $(seq 1 20); do
  api GET "/pulls?state=closed&sort=recentupdate&limit=50&page=${page}" >"${tmp}/batch.json"
  jq -c --slurpfile commits "${tmp}/commits.json" --arg head "$HEAD" '
    $commits[0] as $commits
    | .[]
    | select(.merged_at != null and .base.ref == $head)
    | select($commits == null or (.merge_commit_sha | IN($commits[])))
  ' "${tmp}/batch.json" >>"${tmp}/pulls.jsonl"
  if [[ $(jq length "${tmp}/batch.json") -lt 50 ]]; then
    break
  fi
done
jq -s . "${tmp}/pulls.jsonl" >"${tmp}/pulls.json"

echo "Pull requests included: $(jq length "${tmp}/pulls.json")"

# --- categorize + version --------------------------------------------------

jq -n \
  --slurpfile config "${tmp}/config.json" \
  --slurpfile pulls "${tmp}/pulls.json" \
  --arg base_tag "$base_tag" '
  def labels_of: (.labels // []) + (if .label then [.label] else [] end);
  def category_labels: labels_of + ((.when // {}) | labels_of);
  def replace($from; $to): split($from) | join($to);

  $config[0] as $config
  | $pulls[0] as $pulls
  | ($config.categories // []) as $categories
  | ($config["version-resolver"] // {}) as $resolver
  | def resolver_labels($kind):
      (($resolver[$kind] // {}) | labels_of)
      + [$categories[] | select(.["semver-increment"] == $kind) | category_labels[]];

  ($config["change-template"] // "* $TITLE (#$NUMBER) @$AUTHOR") as $change_template
  | (($config["change-title-escapes"] // "") | replace("\\"; "")) as $escapes
  | def escape_title: split("") | map(if . as $ch | $escapes | contains($ch) then "\\" + . else . end) | join("");
    def render_change:
      . as $pr
      | $change_template
      | replace("$TITLE"; $pr.title // "" | escape_title)
      | replace("$NUMBER"; $pr.number | tostring)
      | replace("$AUTHOR"; $pr.user.login // "")
      | replace("$BODY"; $pr.body // "")
      | replace("$URL"; $pr.html_url // "");

  ([$pulls[].labels[]?.name | select(. != null and . != "")] | unique) as $all_labels
  | def has_any($labels): any($all_labels[]; IN($labels[]));
  (if has_any(resolver_labels("major")) then "major"
   elif has_any(resolver_labels("minor")) then "minor"
   elif has_any(resolver_labels("patch")) then "patch"
   else $resolver.default // "patch" end) as $bump

  | (($base_tag | capture("(?<a>\\d+)\\.(?<b>\\d+)\\.(?<c>\\d+)") | [.a, .b, .c] | map(tonumber)) // [0, 0, 0]
    | if $bump == "major" then [.[0] + 1, 0, 0]
      elif $bump == "minor" then [.[0], .[1] + 1, 0]
      else [.[0], .[1], .[2] + 1] end
    | map(tostring) | join(".")) as $version

  | (reduce ($categories[] | select((.type // "changelog") == "changelog" and .title)) as $category
      ({used: [], sections: []};
        . as $state
        | ($category | category_labels) as $labels
        | [$pulls[] | select((.number | IN($state.used[]) | not) and any(.labels[]?.name; IN($labels[])))] as $matched
        | if ($matched | length) == 0 then .
          else .used += [$matched[].number]
            | .sections += ["## \($category.title)\n\n" + ($matched | map(render_change) | join("\n"))]
          end)) as $state
  | [$pulls[] | select(.number | IN($state.used[]) | not)] as $uncategorized
  | ($state.sections + (if ($uncategorized | length) > 0 then [$uncategorized | map(render_change) | join("\n")] else [] end)) as $sections
  | (if ($sections | length) > 0 then $sections | join("\n\n") else $config["no-changes-template"] // "* No changes" end) as $changes

  | {
      bump: $bump,
      version: $version,
      labels: ($all_labels | join(",")),
      name: (($config["name-template"] // "v$RESOLVED_VERSION") | replace("$RESOLVED_VERSION"; $version)),
      tag: (($config["tag-template"] // "v$RESOLVED_VERSION") | replace("$RESOLVED_VERSION"; $version)),
      body: (($config.template // "$CHANGES")
        | replace("$CHANGES"; $changes)
        | replace("$RESOLVED_VERSION"; $version)
        | replace("$PREVIOUS_TAG"; $base_tag))
    }
' >"${tmp}/result.json"

bump=$(jq -r .bump "${tmp}/result.json")
resolved_version=$(jq -r .version "${tmp}/result.json")
release_name=$(jq -r .name "${tmp}/result.json")
release_tag=$(jq -r .tag "${tmp}/result.json")
echo "Version bump: ${bump} -> ${resolved_version}"

# --- upsert draft ----------------------------------------------------------

payload=$(jq -c --arg head "$HEAD" '{
  tag_name: .tag, name: .name, body: .body,
  draft: true, prerelease: false, target_commitish: $head
}' "${tmp}/result.json")

if [[ -n "$draft_id" ]]; then
  api PATCH "/releases/${draft_id}" "$payload" >/dev/null
  echo "Updated draft release ${draft_id} -> ${release_name}"
else
  created_id=$(api POST "/releases" "$payload" | jq -r .id)
  echo "Created draft release ${created_id} -> ${release_name}"
fi

# --- outputs ---------------------------------------------------------------

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    echo "resolved-version=${resolved_version}"
    echo "tag-name=${release_tag}"
    echo "bump=${bump}"
    echo "labels=$(jq -r .labels "${tmp}/result.json")"
  } >>"$GITHUB_OUTPUT"
fi
