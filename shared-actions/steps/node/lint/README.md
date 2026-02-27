<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->
## Description

This run lint command for Node.js application

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `checkout` | <p>Whether to checkout the repository (set to false if already done in a previous step)</p> | `false` | `true` |
| `command` | <p>Specify what is the command to lint</p> | `false` | `lint` |
| `nodeVersion` | <p>Node.js version to use</p> | `false` | `25` |
| `pnpmVersion` | <p>PNPM version to use (step skipped when not set)</p> | `false` | `""` |
| `throwOnError` | <p>Set to false if error should be silenced</p> | `false` | `true` |
| `workingDirectory` | <p>Directory to run lint commands in</p> | `false` | `.` |


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
    # Specify what is the command to lint
    #
    # Required: false
    # Default: lint

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

    throwOnError:
    # Set to false if error should be silenced
    #
    # Required: false
    # Default: true

    workingDirectory:
    # Directory to run lint commands in
    #
    # Required: false
    # Default: .
```
<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->

