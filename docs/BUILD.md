# Build Images

This discusses the build system for the images provided in this project.

To build all the images locally for testing, run:

```bash
./scripts/build-all.sh
```

## Scripts

These files live in the [scripts](../scripts) directory.

| File | Description |
|------- | ---------- |
| `ci.sh` | Invokes `build-all.sh`, `test.sh`, and `push-all.sh`.   |
| `build-all.sh` | Builds all variants described in the [variants](../variants) file. |
| `build-chain.sh` | Builds one variant. |
| `push-all.sh`  | Pushes all tags created during the current build. |
| `test.sh` | Runs tests on the `akamai/shell` image. |
| `env.sh` | Sourced by all the other scripts, provides shared utils and environment values. |

In general, `build-all.sh` and `build-chain.sh` can be invoked locally for testing, but pushing is done by CI.

## Chain

The [variants](../variants) file describes all the images that should be built, one so-called chain per line.

A chain is simply a list of Dockerfiles that must be layered on top of each other to form the final image.

A simple chain providing interactive access to `akamai purge` might look like this:

```bash
cli purge shell
```

Invoking `build-chain.sh cli purge shell` will do the following:

1. Builds `akamai/purge-chain`, using the Dockerfile `dockerfiles/purge.Dockerfile` and `akamai/cli` as its base image.
2. Builds `akamai/shell`, using the Dockerfile `dockerfiles/shell.Dockerfile` and  `akamai/purge-chain` as its base image.

## Labels

All the images are labeled using a subset of [label schema](http://label-schema.org/rc1/), details are in `build-chain.sh`.

Some labels are not added for local builds (if `CI` env var is not `true`) to maximize layer cache reuse. For example, including the build time label invalidates the cache systematically because each label creates a layer.

## Builds

### Build on git push (CI)

CI is triggered, with the expectation that these environment variables are set:

```bash
CI=true
GITHUB_RUN_NUMBER=N
GITHUB_REF_NAME=branch/tag
```

The variants are all built, tagged as `latest`, and pushed.

### Build on a monthly schedule (CI)

CI is triggered, with the expectation that these environment variables are set:

```bash
CI=true
GITHUB_RUN_NUMBER=N
GITHUB_REF_NAME=branch/tag
```

The variants are all built. In addition to `latest`, a timestamp tag is also created. Both `latest` and the timestamp tag are pushed.

### Local builds

Useful for local development, you can directly invoke `build-all.sh` or `build-chain.sh`. Depending on the platform, the images
are assigned `local-arm64` or `local-amd64` tags.

Note that you can't invoke `build-chain.sh base cli` without first invoking `build-chain.sh base`, because the first image in a chain is not implicitly built.

> You can push locally by simulating the environment provided by CI (see above) and invoking `ci.sh`.
> Make sure to do this in a way that doesn't clobber existing images unintentionally.
>
> Because a local build doesn't provide a build number, this value is suggested:
>
> ```bash
> GITHUB_RUN_NUMBER=local
> ```

You can pass additional arguments for the `docker build` command by setting the `DOCKER_BUILD_EXTRA_ARGS` env variable. You can use it to set additional `--build-args` in the variant's Dockerfile.

For example, you can customize the git repository for a specific variant only if the specific variant supports setting the repository URL from `--build-arg`.

```bash
DOCKER_BUILD_EXTRA_ARGS="--build-arg CLI_REPOSITORY_URL=git://host.docker.internal/cli" ./scripts/build-chain.sh base cli
```

Setting `CLI_REPOSITORY_URL` will cause `cli.Dockerfile` to use the `git://host.docker.internal/cli` repository instead of the default `https://github.com/akamai/cli` for building the CLI binary.

> If you want a specific variant's Dockerfile to support this feature, update the Dockerfile by adding the `ARG` directive with a descriptive name, for example:
>
> `<VARIANT_NAME>_REPOSITORY_URL` 
>
> The default value should point to the existing GitHub repository. You will also have to substitute the argument in the `RUN` directive with the new build argument.
>
> See `cli.Dockerfile` to find an example of how you can implement this.

## Reasons why builds take time

* Python images without a build stage (CPS, HTTPie).
  * We incur the build price both for single derivatives and for the shell.
  * For images with a build stage, the cache is reused for the shell.
* UPX executable compression.
  * All Go images, in particular CLI and Terraform.
  * For Terraform, running UPX can take about five minutes. It takes 20% of the original size, each plugin is 20MB.