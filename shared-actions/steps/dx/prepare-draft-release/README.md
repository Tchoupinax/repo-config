<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->
## Description

When a pull request is merged, this runs on main branch and analyze labels to prepare the next release. It will update the current draft release or create it with updates

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `appId` | <p>ID of the GitHub app (used when token is empty)</p> | `false` | `""` |
| `checkout` | <p>Whether to checkout the repository (set to false if already done in a previous step)</p> | `false` | `true` |
| `configName` | <p>Release-drafter config file name (resolved under .github/ when loaded from the repository)</p> | `false` | `release-drafter.yml` |
| `privateKey` | <p>Private key of the GitHub app (used when token is empty)</p> | `false` | `""` |
| `serverHost` | <p>API hostname or URL for release-drafter GHE<em>HOST (e.g. git.example.com or gitea.server</em>url)</p> | `false` | `""` |
| `token` | <p>Repository token for checkout and release-drafter; uses GitHub app when empty</p> | `false` | `""` |
| `workingDirectory` | <p>Reserved for future use; currently unused</p> | `false` | `.` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: tchoupinax/repo-config@v0
  with:
    appId:
    # ID of the GitHub app (used when token is empty)
    #
    # Required: false
    # Default: ""

    checkout:
    # Whether to checkout the repository (set to false if already done in a previous step)
    #
    # Required: false
    # Default: true

    configName:
    # Release-drafter config file name (resolved under .github/ when loaded from the repository)
    #
    # Required: false
    # Default: release-drafter.yml

    privateKey:
    # Private key of the GitHub app (used when token is empty)
    #
    # Required: false
    # Default: ""

    serverHost:
    # API hostname or URL for release-drafter GHE_HOST (e.g. git.example.com or gitea.server_url)
    #
    # Required: false
    # Default: ""

    token:
    # Repository token for checkout and release-drafter; uses GitHub app when empty
    #
    # Required: false
    # Default: ""

    workingDirectory:
    # Reserved for future use; currently unused
    #
    # Required: false
    # Default: .
```
<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->
