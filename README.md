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

## Renovate configuration

The dashboard is accessible [here](https://developer.mend.io/github/Tchoupinax). To add an app, use this [page](https://github.com/settings/installations/53876128).

Renovate won't merge automatically if there is no check passed ([source](https://github.com/renovatebot/renovate/discussions/13485#discussioncomment-1946614)).
