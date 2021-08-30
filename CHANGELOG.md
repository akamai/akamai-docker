# CHANGELOG


## v2.2.1 (2021-08-30)

* fixed 404 for akamai/terraform-cli href (#59) - Walter Lee (57d3888)

## v2.2.0 (2021-05-06)

* Initial build for aarch64 (raspberry pi and Apple Silicon) (#55) - John Payne (7432fd0)


## v2.1.0 (2021-04-14)

* Allow passing custom repository to cli.Dockerfile through build-chain.sh (#56) - Piotr Piotrowski (2bc5ea5)
* Add ETP feature (#53) - John Payne (d1fb1d2)


## v2.0.1 (2021-03-16)

* Fix test.bats akamai executable test - Piotrowski, Piotr (0a72792)
* Align cli.Dockerfile with akamai/cli release v1.2.0 - Piotrowski, Piotr (5e2a971)


## v2.0.0 (2021-02-27)

* break: upgrade to terraform 0.13.6 (#29) - Anthony Hogg (69032af)
* fix: docker login before build - Anthony Hogg (6aa2dc3)
* fix: update go package builds to satisfy golang 1.16 - Anthony Hogg (5cfa812)


## v1.0.2 (2021-02-09)

* update alpine to 3.12
* fix: temporary fix for cryptography package - Lukasz Czerpak (9b7f6cd)


## v1.0.1 (2021-01-07)

* Fix/missing cachedir in config (#47) - Łukasz Czerpak (9f4d984)


## v1.0.0 (2020-12-14)

This is the first official release, marking the beginning of semver for this repository :sunrise:.

* feat: allow travis to build semver tags - Anthony Hogg (cc88310)
* feat: implement semver and changelog (#33) - Anthony Hogg (476c3ba)
* updated missed module - Lukasz Czerpak (fe28424)
* fixed typo in builder name - Lukasz Czerpak (7ccb999)
* updated variants to use explicit alpine and runtime version - Lukasz Czerpak (94d149c)
* add cli-jsonnet (#32) - Anthony Hogg (b9c226d)
* updated README - Lukasz Czerpak (ad63397)
* added cli-eaa variant - Lukasz Czerpak (94f31c1)
* remove --auth-type=edgegrid from httpie-conf.json (fixes #27) (#30) - Anthony Hogg (26fc408)
* added cli-onboard image - Lukasz Czerpak (efe5e16)
* removed trailing spaces - Javier Garza (11f2c06)
* documentation updates - Javier Garza (a20f927)
* updates to readme - Javier Garza (cbaa568)
* cli-dns: switch from dep ensure to go mod - Anthony Hogg (b7b91ce)
* add quickstart section - Anthony Hogg (cda685a)
* placeholder file - Javier Garza (b1398a1)
* Expanding README - Javier Garza (60e7a74)
* Update README.md - Łukasz Czerpak (1fc5961)
* fix cron build - Anthony Hogg (23e8d7b)
* add terraform-cli variant (#14) - Anthony Hogg (1842988)
* introduce variants system (closes #2, closes #5) - Anthony Hogg (0d8bc13)
* added missing JAVA_HOME environment variable - Lukasz Czerpak (234149b)
* improved sandbox cli - Lukasz Czerpak (4fc751b)
* added missing patches - Lukasz Czerpak (1ed6c89)
* full image size reduction - Lukasz Czerpak (ab460d7)
* removing quotes from sample command - Javier Garza (baf927f)
* remove single quotes [skip ci] - Anthony Hogg (39ff994)
* rename Edgegrid -> EdgeGrid #6 - Anthony Hogg (60c8a6f)
* add explicit wording around .edgerc management #6 - Anthony Hogg (4079fa1)
* add slack notifications - Anthony Hogg (49a71ef)
* adding copyright - Javier Garza (654a567)
* adding copyright text - Javier Garza (5b570ea)
* fix typos - Anthony Hogg (f83e735)
* limit to master - Anthony Hogg (178e9ea)
* fix scripts dir in .dockerignore - Anthony Hogg (85e0a05)
* restrict to master - Anthony Hogg (c53f437)
* use travis - Anthony Hogg (5639f0e)
* adding .gitignore file - Javier Garza (05382d0)
* added copyright and license info - Lukasz Czerpak (bd37bf6)
* Create LICENSE - Łukasz Czerpak (ae30ff8)
* added maintainer info - Lukasz Czerpak (5f73fec)
* initial version - Lukasz Czerpak (007bf98)
* renamed repo name - Javier Garza (9da3cff)
* Initial commit - Javier Garza (2c54e38)


