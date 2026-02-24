<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->
## Description

This uses golanci for this goal

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `workingDirectory` | <p>Directory containing go.mod (default repo root)</p> | `false` | `.` |


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
```
<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->

