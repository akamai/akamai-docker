# Release notes

## v2.33.2 (Oct 21, 2025)

* Upgraded Akamai Terraform Provider to `v9.1.0`.

## v2.33.1 (Sep 9, 2025)

* Upgraded Akamai Terraform Provider to `v9.0.1`.

## v2.33.0 (Sep 5, 2025)

* Upgraded Akamai Terraform Provider to `v9.0.0`.

## v2.32.0 (Aug 8, 2025)

* Upgraded Akamai Terraform Provider to `v8.1.0`.

## v2.31.0 (May 29, 2025)

* Upgraded Akamai Terraform Provider to `v8.0.0`.

## v2.30.0 (Apr 8, 2025)

* Upgraded Akamai Terraform Provider to `v7.1.0`.
* Upgraded Go to version `1.23.8` and Alpine to `3.21` for `dns`, `cli`, `gtm`, `jsonnet`, `purge`, `terraform-cli`, and `test-center` images.

## v2.29.0 (Feb 7, 2025)

* Upgraded Akamai Terraform Provider to `v7.0.0`.
* Upgraded Go to version `1.22.9` for `dns`, `cli`, `gtm`, `jsonnet`, `purge`, `terraform-cli`, and `test-center` images.

## v2.28.0 (Dec 20, 2024)

* Upgraded Akamai Terraform Provider to `v6.6.1`.

## v2.27.0 (Nov 22, 2024)

* Resolved a problem with the EdgeWorkers CLI hitting certificate issues in akamai/shell Docker image.
* Upgraded Akamai Terraform Provider to `v6.6.0`.

## v2.26.0 (Oct 14, 2024)

* Upgraded Alpine to `3.19` for `base`.
  * Upgraded Node to version `node:18-alpine3.19` for `appsec`, `edgeworkers`, `sandbox`, and `property-manager`.
  * Upgraded Go to version `1.21` for `dns`, `cli`, `gtm`, `jsonnet`, `purge`, `terraform-cli`, `test-center`, and `api-gateway`.
  * Added the Python virtual environment in `httpie` to support Alpine `3.19`.
  * Upgraded Alpine to version `alpine:3.19` for `terraform`.
  * Restored using the latest versions of the `onboard` and `cloudlets` packages.
* Upgraded Akamai Terraform Provider to `v6.5.0`.

## v2.25.0 (Sep 5, 2024)

* Changed locally built images tags to `local-amd64` or `local-arm64`.
* Upgraded Akamai Terraform Provider to `v6.4.0`.

## v2.24.0 (Jul 17, 2024)

* Upgraded Akamai Terraform Provider to `v6.3.0`.

## v2.23.0 (May 29, 2024)

* Upgraded Akamai Terraform Provider to `v6.2.0`.

## v2.22.0 (Apr 23, 2024)

* Upgraded Akamai Terraform Provider to `v6.1.0`.

## v2.21.0 (Mar 26, 2024)

* Upgraded Akamai Terraform Provider to `v6.0.0`.

## v2.20.0 (Feb 20, 2024)

* Upgraded Akamai Terraform Provider to `v5.6.0`.

## v2.19.0 (Dec 8, 2023)

* Upgraded Akamai Terraform Provider to `v5.5.0`.

## v2.18.0 (Nov 2, 2023)

* Upgraded Akamai Terraform Provider to `v5.4.0`.

## v2.17.0 (Sep 27, 2023)

* Upgraded Akamai Terraform Provider to `v5.3.0`.

## v2.16.0 (Sep 1, 2023)

* Added image `akamai/test-center` and included `test-center` for the CLI in `akamai/shell`.
* Upgraded Akamai Terraform Provider to `v5.2.0`.

## v2.15.0 (Aug 8, 2023)

* Upgraded Akamai Terraform Provider to `v5.1.0`.

## v2.14.0 (Jul 14, 2023)

* Upgraded Terraform to version `1.4.6`.
* Froze the `cli-cloudlets` and `cli-onboard` versions until further notice.
* Upgraded Akamai Terraform Provider to `v5.0.1`.

## v2.13.0 (Jun 2, 2023)

* Upgraded Akamai Terraform Provider to `v4.1.0`.

## v2.12.1 (Apr 28, 2023)

* Fixed building `purge` and `sandbox` images.

## v2.12.0 (Apr 27, 2023)

* Upgraded Akamai Terraform Provider to `v3.6.0`.

## v2.11.0 (Apr 3, 2023)

* Upgraded Akamai Terraform Provider to `v3.5.0`.

## v2.10.0 (Mar 6, 2023)

* Upgraded Akamai Terraform Provider to `v3.4.0`.

## v2.9.0 (Feb 2, 2023)

* Upgraded Akamai Terraform Provider to `v3.3.0`.

## v2.8.1 (Dec 19, 2022)

* Upgraded Akamai Terraform Provider to `v3.2.1`.

## v2.8.0 (Dec 15, 2022)

* Upgraded Akamai Terraform Provider to `v3.2.0`.

## v2.7.0 (Dec 5, 2022)

* Upgraded Akamai Terraform Provider to `v3.1.0`.

## v2.6.0 (Oct 28, 2022)

* Upgraded Akamai Terraform Provider to `v3.0.0`.

## v2.5.0 (Oct 20, 2022)

* Upgraded Akamai Terraform Provider to `v2.4.2`.
* Moved from Travis CI to GitHub Actions.
* Added support for Mac M1 in Docker.
* Upgraded Terraform to version `1.2.5`.
* Updated `dockerfiles` for CLI `1.4.0`.
* Updated `README` and the CLI sanity test.
* Updated the `gtm.Dockerfile` file for the CLI.

## v2.4.0 (Dec 28, 2021)

* Add the `gtm.Dockerfile` file for the CLI (#66).
* Updated comments to match build logic.
* Added a fix not to tag the cron builds.

## v2.3.2 (Sep 1, 2021)

* Added a fix to tag the current commit, not the changelog commit.

## v2.3.1 (Sep 1, 2021)

* Upgraded to Alpine `3.13` (#48).

## v2.3.0 (Aug 30, 2021)

* Added all-access to `/cli` and `/workdir` to avoid jenkins perm issues (#38).

## v2.2.0 (May 6, 2021)

* Initial build for aarch64 (Raspberry Pi and Apple Silicon) (#55).

## v2.1.0 (Apr 14, 2021)

* Enabled passing a custom repository to `cli.Dockerfile` through `build-chain.sh` (#56).
* Added the Enterprise Threat Protector (ETP) feature (#53).

## v2.0.1 (Mar 16, 2021)

* Fixed the `test.bats` executable test.
* Aligned `cli.Dockerfile` with the `akamai/cli` release for `v1.2.0`.

## v2.0.0 (Feb 27, 2021)

* Upgraded to Terraform `0.13.6` (#29).
* Added `docker-login` before build.
* Updated the Go package builds to satisfy Golang `1.16`.

## v1.0.2 (Feb 9, 2021)

* Updated Alpine to `3.12`
* Added a temporary fix for a cryptography package.

## v1.0.1 (Jan 7, 2021)

* Added a missing `cachedir` in the config (#47).

## v1.0.0 (Dec 14, 2020)

* The first official release, marking the beginning of semver for this repository.