<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->
## Description

When releasing a package that can be installed with brew, update the version and the hash in the registry on Github

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `formulaPath` | <p>Path of your fomrmula inside the repository</p> | `true` | `""` |
| `patToken` | <p>PAT for your Github account</p> | `true` | `""` |
| `repositoryName` | <p><owner>/<repo_name> of your registry on Github</p> | `false` | `Tchoupinax/homebrew-brew` |
| `workingDirectory` | <p>Reserved for future use; currently unused</p> | `false` | `.` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: tchoupinax/repo-config@v0
  with:
    formulaPath:
    # Path of your fomrmula inside the repository
    #
    # Required: true
    # Default: ""

    patToken:
    # PAT for your Github account
    #
    # Required: true
    # Default: ""

    repositoryName:
    # <owner>/<repo_name> of your registry on Github
    #
    # Required: false
    # Default: Tchoupinax/homebrew-brew

    workingDirectory:
    # Reserved for future use; currently unused
    #
    # Required: false
    # Default: .
```
<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->

