<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->
## Description

When a pull request is merged, this runs on main branch and analyze labels to prepare the next release. It will update the current draft release or create it with updates

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `appId` | <p>ID of the Github app</p> | `true` | `""` |
| `privateKey` | <p>Private key of the Github app</p> | `true` | `""` |


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
```
<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->

