<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->
## Description

This is my standard pipeline for pull request on Golang project

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `appId` | <p>ID of the Github app</p> | `true` | `""` |
| `privateKey` | <p>Private key of the Github app</p> | `true` | `""` |
| `workingDirectory` | <p>Directory containing the Go project (passed to underlying actions)</p> | `false` | `.` |


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
    # Directory containing the Go project (passed to underlying actions)
    #
    # Required: false
    # Default: .
```
<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->

