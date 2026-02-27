<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->
## Description

Build a multi-architecture Docker image and push it to container registries.

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `buildArgs` | <p>Additional build args for docker/build-push-action (newline-separated KEY=VALUE)</p> | `false` | `""` |
| `checkout` | <p>Whether to checkout the repository (set to false if already done in a previous step)</p> | `false` | `true` |
| `context` | <p>Docker build context, relative to workingDirectory</p> | `false` | `.` |
| `dockerhubToken` | <p>Docker Hub access token or password (required if enableDockerHub is true)</p> | `false` | `""` |
| `dockerhubUsername` | <p>Docker Hub username (required if enableDockerHub is true)</p> | `false` | `""` |
| `enableDockerHub` | <p>Whether to log in to and push images to Docker Hub</p> | `false` | `false` |
| `enableGhcr` | <p>Whether to log in to and push images to GitHub Container Registry (ghcr.io)</p> | `false` | `true` |
| `file` | <p>Path to Dockerfile, relative to the build context (optional)</p> | `false` | `""` |
| `flavor` | <p>Flavor configuration passed to docker/metadata-action (e.g. latest=true)</p> | `false` | `latest=true` |
| `images` | <p>Newline-separated list of image names to tag and publish (e.g.: ghcr.io/owner/app owner/app)</p> | `true` | `""` |
| `platforms` | <p>Target platforms for the image build</p> | `false` | `linux/amd64,linux/arm64` |
| `push` | <p>Whether to push the built image(s) to the registry</p> | `false` | `true` |
| `tags` | <p>Tag configuration passed to docker/metadata-action</p> | `false` | `type=ref,event=branch type=ref,event=pr type=semver,pattern={{raw}} ` |
| `workingDirectory` | <p>Base directory for the Docker context (typically the repository root)</p> | `false` | `.` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: tchoupinax/repo-config@v0
  with:
    buildArgs:
    # Additional build args for docker/build-push-action (newline-separated KEY=VALUE)
    #
    # Required: false
    # Default: ""

    checkout:
    # Whether to checkout the repository (set to false if already done in a previous step)
    #
    # Required: false
    # Default: true

    context:
    # Docker build context, relative to workingDirectory
    #
    # Required: false
    # Default: .

    dockerhubToken:
    # Docker Hub access token or password (required if enableDockerHub is true)
    #
    # Required: false
    # Default: ""

    dockerhubUsername:
    # Docker Hub username (required if enableDockerHub is true)
    #
    # Required: false
    # Default: ""

    enableDockerHub:
    # Whether to log in to and push images to Docker Hub
    #
    # Required: false
    # Default: false

    enableGhcr:
    # Whether to log in to and push images to GitHub Container Registry (ghcr.io)
    #
    # Required: false
    # Default: true

    file:
    # Path to Dockerfile, relative to the build context (optional)
    #
    # Required: false
    # Default: ""

    flavor:
    # Flavor configuration passed to docker/metadata-action (e.g. latest=true)
    #
    # Required: false
    # Default: latest=true

    images:
    # Newline-separated list of image names to tag and publish (e.g.:
    # ghcr.io/owner/app
    # owner/app)
    #
    # Required: true
    # Default: ""

    platforms:
    # Target platforms for the image build
    #
    # Required: false
    # Default: linux/amd64,linux/arm64

    push:
    # Whether to push the built image(s) to the registry
    #
    # Required: false
    # Default: true

    tags:
    # Tag configuration passed to docker/metadata-action
    #
    # Required: false
    # Default: type=ref,event=branch type=ref,event=pr type=semver,pattern={{raw}} 

    workingDirectory:
    # Base directory for the Docker context (typically the repository root)
    #
    # Required: false
    # Default: .
```
<!-- action-docs-all source="action.yml" project="tchoupinax/repo-config" version="v0" -->

