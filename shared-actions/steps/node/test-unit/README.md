<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->
## Description

This allow to run test for your Node.js application

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `nodeVersion` | <p>Node.js version to use</p> | `false` | `25` |
| `command` | <p>Specify what is the command to run tests</p> | `false` | `tests` |
| `pnpmVersion` | <p>PNPM version to use (step skipped when not set)</p> | `false` | `""` |
| `workingDirectory` | <p>Directory to run test commands in</p> | `false` | `.` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: tchoupinax/repo-config@v0
  with:
    nodeVersion:
    # Node.js version to use
    #
    # Required: false
    # Default: 25

    command:
    # Specify what is the command to run tests
    #
    # Required: false
    # Default: tests

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

