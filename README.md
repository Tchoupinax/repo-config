# repo-config

## Shared GitHub Actions

This repository is also a **catalog of reusable GitHub Actions** that power many of my projects.  
Each action is fully documented and kept in sync with its `action.yml` via `action-docs`.

- **Node steps**
  - **Build**: [`shared-actions/steps/node/build`](shared-actions/steps/node/build/README.md)
  - **Unit tests**: [`shared-actions/steps/node/test-unit`](shared-actions/steps/node/test-unit/README.md)
  - **Lint**: [`shared-actions/steps/node/lint`](shared-actions/steps/node/lint/README.md)

- **Golang steps**
  - **golangci-lint**: [`shared-actions/steps/golang/golangci`](shared-actions/steps/golang/golangci/README.md)
  - **Goreleaser (build-only)**: [`shared-actions/steps/golang/goreleaser-build-only`](shared-actions/steps/golang/goreleaser-build-only/README.md)
  - **Goreleaser (release)**: [`shared-actions/steps/golang/goreleaser-release`](shared-actions/steps/golang/goreleaser-release/README.md)

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

CI will fail if any of these docs are out of date, so every merged PR ships with **up‑to‑date action documentation by construction**.

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
