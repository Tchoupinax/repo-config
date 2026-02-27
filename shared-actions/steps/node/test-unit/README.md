<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->
## Description

This allow to run test for your Node.js application

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `checkout` | <p>Whether to checkout the repository (set to false if already done in a previous step)</p> | `false` | `true` |
| `command` | <p>Specify what is the command to run tests</p> | `false` | `tests` |
| `nodeVersion` | <p>Node.js version to use</p> | `false` | `25` |
| `pnpmVersion` | <p>PNPM version to use (step skipped when not set)</p> | `false` | `""` |
| `workingDirectory` | <p>Directory to run test commands in</p> | `false` | `.` |


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

    command:
    # Specify what is the command to run tests
    #
    # Required: false
    # Default: tests

    nodeVersion:
    # Node.js version to use
    #
    # Required: false
    # Default: 25

    pnpmVersion:
    # PNPM version to use (step skipped when not set)
    #
    # Required: false
    # Default: ""

    workingDirectory:
    # Directory to run test commands in
    #
    # Required: false
    # Default: .
```
<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->

