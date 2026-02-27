<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->
## Description

This uses golanci for this goal

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `workingDirectory` | <p>Directory containing go.mod (default repo root)</p> | `false` | `.` |
| `checkout` | <p>Whether to checkout the repository (set to false if already done in a previous step)</p> | `false` | `true` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: tchoupinax/repo-config@v0
  with:
    workingDirectory:
    # Directory containing go.mod (default repo root)
    #
    # Required: false
    # Default: .

    checkout:
    # Whether to checkout the repository (set to false if already done in a previous step)
    #
    # Required: false
    # Default: true
```
<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->

