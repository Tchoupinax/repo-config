# repo-config

Terraform configuration for GitHub repositories, plus a **catalog of reusable composite GitHub Actions** used across managed projects.

## Guide

Use this section when you need to wire, debug, or extend GitHub Actions in this repo or in a repository managed by it.

### Where to find documentation

| What you need | Where to look |
| --- | --- |
| Full catalog and repo-wide rules | This README |
| Inputs, defaults, and usage for one action | `shared-actions/**/README.md` next to the action (e.g. [`shared-actions/steps/node/build/README.md`](shared-actions/steps/node/build/README.md)) |
| Source of truth for behavior | `shared-actions/**/action.yml` |
| Example workflow in this repo | [`.github/workflows/`](.github/workflows/) |
| Example workflow in a consumer repo | `.github/workflows/` in the target repo (often `pull-request.yml`, `master.yml`, `tag.yml`) |
| Allowed third-party actions | `local.allowed_action_patterns` in [`repositories.tf`](repositories.tf) |

Per-action README files are generated from `action.yml` with [action-docs](https://github.com/npalm/action-docs). If you change an action, regenerate docs (see below) or CI will fail.

### Layout

```
shared-actions/
  steps/          # Single-purpose composite actions (build, lint, release, ...)
    node/
    golang/
    rust/
    docker/
    dx/
  flows/          # Composite actions that orchestrate several steps
    golang/
```

- **Steps**: one job concern (install deps, build, lint, label PRs, ...).
- **Flows**: ready-made pipelines that call multiple steps (e.g. Golang pull-request checks).

### How to reference an action

**In a managed consumer repo** (helm-viewer, image-operator, ...), pin to a tag or SHA:

```yaml
- uses: tchoupinax/repo-config/shared-actions/steps/node/build@v0
  with:
    nodeVersion: "25"
    workingDirectory: "."
```

Pattern: `tchoupinax/repo-config/<path-to-action-directory>@<ref>`

The path is the directory that contains `action.yml`, without `/action.yml` at the end.

**Inside repo-config itself**, use a local path (no tag):

```yaml
- uses: ./shared-actions/steps/dx/automatically-apply-labels
  with:
    appId: ${{ secrets.DEPLOY_APP_ID }}
    privateKey: ${{ secrets.DEPLOY_APP_KEY }}
```

### How to pick the right action

1. List directories under `shared-actions/steps/` and `shared-actions/flows/` for available actions.
2. Open the matching `README.md` for inputs and defaults.
3. Read `action.yml` if you need conditionals, nested steps, or exact third-party action pins.
4. Prefer an existing **flow** when it matches the use case; otherwise compose **steps** in the consumer workflow.

Common Node.js PR pipeline:

```yaml
jobs:
  lint:
    steps:
      - uses: tchoupinax/repo-config/shared-actions/steps/node/lint@v0
  build:
    steps:
      - uses: tchoupinax/repo-config/shared-actions/steps/node/build@v0
  labels:
    steps:
      - uses: tchoupinax/repo-config/shared-actions/steps/dx/automatically-apply-labels@v0
        with:
          appId: ${{ secrets.DEPLOY_APP_ID }}
          privateKey: ${{ secrets.DEPLOY_APP_KEY }}
```

### How to change or add an action

1. Edit `shared-actions/**/action.yml` (inputs, steps, pins).
2. Regenerate docs: `bash scripts/generate-actions-docs.sh`
3. Commit both `action.yml` and the updated `README.md`.
4. If the action pulls in a new third-party action, add its pattern to `local.allowed_action_patterns` in [`repositories.tf`](repositories.tf).
5. Tag or bump `@v0` in consumer repos when you want them to pick up the change.

Do not hand-edit the HTML comment blocks in generated README files; they are managed by action-docs.

### Debugging CI failures

1. Identify which composite action failed (`uses:` line in the workflow log).
2. Open its `action.yml` and README to see inputs and nested steps.
3. For managed repos, confirm the `@ref` points to a commit that contains your fix.
4. Check whether a third-party action is blocked by the [allowlist](#github-actions-allowlist).

## Shared GitHub Actions

Each action is documented in its directory and kept in sync with `action.yml` via `action-docs`.

- **Node steps**
  - **Build**: [`shared-actions/steps/node/build`](shared-actions/steps/node/build/README.md)
  - **Unit tests**: [`shared-actions/steps/node/test-unit`](shared-actions/steps/node/test-unit/README.md)
  - **Lint**: [`shared-actions/steps/node/lint`](shared-actions/steps/node/lint/README.md)

- **Golang steps**
  - **golangci-lint**: [`shared-actions/steps/golang/golangci`](shared-actions/steps/golang/golangci/README.md)
  - **Goreleaser (build-only)**: [`shared-actions/steps/golang/goreleaser-build-only`](shared-actions/steps/golang/goreleaser-build-only/README.md)
  - **Goreleaser (release)**: [`shared-actions/steps/golang/goreleaser-release`](shared-actions/steps/golang/goreleaser-release/README.md)

- **Rust steps**
  - **Build**: [`shared-actions/steps/rust/build`](shared-actions/steps/rust/build/README.md)
  - **Lint**: [`shared-actions/steps/rust/lint`](shared-actions/steps/rust/lint/README.md)

- **Docker steps**
  - **Build image**: [`shared-actions/steps/docker/build-image`](shared-actions/steps/docker/build-image/README.md)

- **DX steps**
  - **Auto-label PRs**: [`shared-actions/steps/dx/automatically-apply-labels`](shared-actions/steps/dx/automatically-apply-labels/README.md)
  - **Prepare draft releases**: [`shared-actions/steps/dx/prepare-draft-release`](shared-actions/steps/dx/prepare-draft-release/README.md)
  - **Update Homebrew registry**: [`shared-actions/steps/dx/update-brew-registry`](shared-actions/steps/dx/update-brew-registry/README.md)

- **Composed flows**
  - **Golang pull-request flow**: [`shared-actions/flows/golang/pull-request`](shared-actions/flows/golang/pull-request/README.md)

To refresh all docs locally:

```bash
bash scripts/generate-actions-docs.sh
```

CI will fail if any of these docs are out of date, so every merged PR ships with **up-to-date action documentation by construction**.

## Token creation

The CI requires TOKEN_GITHUB, a token created that give the following rights:

- `Administration`: Write
- `Contents`: Write
- `Pull requests`: Write

## Terraform apply protection

The `terraform apply` workflow runs in the `terraform` GitHub Environment. Configure it once in the repository settings:

1. Go to **Settings → Environments → New environment** and create `terraform`.
2. Enable **Required reviewers** and add at least one approver.
3. Optionally restrict deployment branches to `master`.

Every apply (including pushes to `master` that change Terraform files) waits for approval before changing GitHub resources.

## Branch protection

By default, managed repositories do not require pull request approvals (so a solo maintainer can merge their own PRs). GitHub does not let PR authors approve their own pull requests.

Set `requiredApprovingReviewCount: 1` in `contents/data.yaml` when a repository should require an external reviewer. `repo-config` enables this.

The `repo-config` repository also requires these CI checks on `master`:

- `Autodetect labels 🔍`
- `Validate shared-actions docs`
- `Plan terraform`

Add `requiredStatusChecks` to a repository entry in `contents/data.yaml` to require additional checks elsewhere.

## GitHub Actions allowlist

Managed repositories only allow GitHub-owned actions, verified publisher actions, and patterns listed in `local.allowed_action_patterns` inside `repositories.tf`. Extend that list when a repository needs a new third-party action.

## Renovate configuration

The dashboard is accessible [here](https://developer.mend.io/github/Tchoupinax). To add an app, use this [page](https://github.com/settings/installations/53876128).

Renovate won't merge automatically if there is no check passed ([source](https://github.com/renovatebot/renovate/discussions/13485#discussioncomment-1946614)).
