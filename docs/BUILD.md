# Build

This discusses the build system for these images.

## TL;DR;

If you're just interested in building all the images locally for testing:

```bash
./scripts/build-all.sh
```

... and go get yourself a cup of coffee.

## Scripts

The following files live in the [scripts](../scripts) directory.

`ci.sh`: invokes `build-all.sh`, `test.sh` and `push-all.sh`.  
`build-all.sh`: builds all variants described in the [variants](../variants) file.  
`build-chain.sh`: builds one variant.  
`push-all.sh`: pushes all tags created during the current build.  
`test.sh`: runs tests on the `akamai/shell` image.  
`env.sh`: sourced by all the other scripts, provides shared utils and environment values.  

In general, `build-all.sh` and `build-chain.sh` can be invoked locally for testing, but pushing is done by CI.

## What is a chain?

The [variants](../variants) file describes all the images that should be built, one so-called chain per line.

A chain is simply a list of Dockerfiles that must be layered on top of each other to form the final image.

A simple chain providing interactive access to `akamai purge` might look like this:

```
cli purge shell
```

Invoking `build-chain.sh cli purge shell` will do the following:

1. build `akamai/purge-chain`, using the Dockerfile `dockerfiles/purge.Dockerfile` and `akamai/cli` as its base image
2. build `akamai/shell`, using the Dockerfile `dockerfiles/shell.Dockerfile` and  `akamai/purge-chain` as its base image

## Labels

All the images are labelled using a subset of [label schema](http://label-schema.org/rc1/), details are in `build-chain.sh`.

Some labels are not added for local builds (if `CI` env var is not `true`) to maximize layer cache reuse. For example, including the build time label invalidates the cache systematically because each label creates a layer.

## Builds

### Build on git push (CI)

CI is triggered, with the expectation that the following environment variables are set:

```
CI=true
TRAVIS_BUILD_NUMBER=N
TRAVIS_EVENT_TYPE=push
```

The variants are all built, tagged as `latest` and pushed.

### Build on monthly schedule (CI)

CI is triggered, with the expectation that the following environment variables are set:

```
CI=true
TRAVIS_BUILD_NUMBER=N
TRAVIS_EVENT_TYPE=cron
```

The variants are all built. In addition to `latest`, a timestamp tag is also created. Both `latest` and the timestamp tag are pushed.

### Local builds

Useful for local development, `build-all.sh` or `build-chain.sh` can be invoked directly.

Note that one cannot invoke `build-chain.sh base cli` without first invoking `build-chain.sh base`, because the first image in a chain is not implicitly built.

> Pushing locally is of course possible by simulating the environment provided by CI (see above) and invoking `ci.sh`.
> Special care should be taken to do this in a way that does not clobber existing images unintentionally.
>
> Because a local build does not provide a build number, the following value is suggested:
>
> ```
> TRAVIS_BUILD_NUMBER=local
> ```

It is possible to customize git repository for a specific variant, provided that the specific variant's Dockerfile contains `<VARIANT_NAME>_REPOSITORY_URL` build argument defined. 

These can be passed to `build-chain.sh` by setting an environment variable with the same name as the build argument when executing the script. For example:
```
CLI_REPOSITORY_URL="git://host.docker.internal/cli" ./scripts/build-chain.sh base cli
```
will use `git://host.docker.internal/cli` repository instead of default `https://github.com/akamai/cli` for building CLI binary.

> If you wish for a specific variant's Dockerfile to support this feature, please update the Dockerfile by adding `ARG` directive with 
> `<VARIANT_NAME>_REPOSITORY_URL` (the default value should point to the existing github repository). You will also have to substitute the argument in `RUN` directive with the new build argument. 
> Please look at `cli.Dockerfile` to find an example of how this can be implemented.

## What is taking time during builds?

* python images without a build stage (cps, httpie)
  * we incur the build price both for single derivatives and for shell
  * for images with a build stage, cache is reused for shell
* upx executable compression
  * all go images, in particular CLI and terraform
  * for terraform, specifically the following take a VERY long time (20 minutes?), but are worth it (20% of original size, each plugin is 20MB)

  ```
  # upx creates a self-extracting compressed executable
  && upx --brute -o/usr/local/bin/akamaiDns.upx /usr/local/bin/akamaiDns \
  # we need to include the cli.json file as well
  && cp "${GOPATH}/src/github.com/akamai/cli-dns/cli.json" /cli.json
  ```

## License

Copyright 2020 Akamai Technologies, Inc.

See [Apache License 2.0](../LICENSE)

By submitting a contribution (the “Contribution”) to this project, and for good and valuable consideration, the receipt and sufficiency of which are hereby acknowledged, you (the “Assignor”) irrevocably convey, transfer, and assign the Contribution to the owner of the repository (the “Assignee”), and the Assignee hereby accepts, all of your right, title, and interest in and to the Contribution along with all associated copyrights, copyright registrations, and/or applications for registration and all issuances, extensions and renewals thereof (collectively, the “Assigned Copyrights”). You also assign all of your rights of any kind whatsoever accruing under the Assigned Copyrights provided by applicable law of any jurisdiction, by international treaties and conventions and otherwise throughout the world.