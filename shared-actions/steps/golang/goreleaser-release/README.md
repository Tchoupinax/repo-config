<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->
## Description

This releases the go binary

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `appId` | <p>ID of the Github app</p> | `true` | `""` |
| `privateKey` | <p>Private key of the Github app</p> | `true` | `""` |
| `workingDirectory` | <p>Directory containing go.mod and .goreleaser (default repo root)</p> | `false` | `.` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: tchoupinax/repo-config@v0
  with:
    appId:
    # ID of the Github app
    #
    # Required: true
    # Default: ""

    privateKey:
    # Private key of the Github app
    #
    # Required: true
    # Default: ""

    workingDirectory:
    # Directory containing go.mod and .goreleaser (default repo root)
    #
    # Required: false
    # Default: .
```
<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->

