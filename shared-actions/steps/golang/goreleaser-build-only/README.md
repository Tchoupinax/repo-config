<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->
## Description

This only build, it's for checking purpose on pull request

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `checkout` | <p>Whether to checkout the repository (set to false if already done in a previous step)</p> | `false` | `true` |
| `workingDirectory` | <p>Directory containing go.mod and .goreleaser (default repo root)</p> | `false` | `.` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: tchoupinax/repo-config@v0
  with:
    checkout:
    # Whether to checkout the repository (set to false if already done in a previous step)
    #
    # Required: false
    # Default: true

    workingDirectory:
    # Directory containing go.mod and .goreleaser (default repo root)
    #
    # Required: false
    # Default: .
```
<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->

