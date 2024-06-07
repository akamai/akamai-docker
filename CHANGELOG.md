# CHANGELOG

## X.X.X (X-X-X)

* DXE-3346 Upgrade alpine to 3.20

## v2.23.0 (2024-05-29)

* DXE-3855 Upgrade akamai terraform provider to v6.2.0

## v2.22.0 (2024-04-23)

* DXE-3742 Upgrade akamai terraform provider to v6.1.0

## v2.21.0 (2024-03-26)

* DXE-3570 Upgrade akamai terraform provider to v6.0.0

## v2.20.0 (2024-02-20)

* DXE-3422 Upgrade akamai terraform provider to v5.6.0

## v2.19.0 (2023-12-08)

* DXE-3199 Upgrade akamai terraform provider to v5.5.0

## v2.18.0 (2023-11-02)

* DXE-3185 Upgrade akamai terraform provider to v5.4.0 - Wojciech Zagrajczuk

## v2.17.0 (2023-09-27)

* DXE-3059 Upgrade akamai terraform provider to v5.3.0 - Dawid Dzhafarov

## v2.16.0 (2023-09-01)

* DXE-2918 Add image akamai/test-center and include test-center cli in akamai/shell - Michal Wojcik
* DXE-2945 Upgrade akamai terraform provider to v5.2.0 - Tatiana Slonimskaia

## v2.15.0 (2023-08-08)

* DXE-2871 Upgrade akamai terraform provider to v5.1.0 - Dawid Dzhafarov (88800bf)

## v2.14.0 (2023-07-14)

* DXE-2670 Rise Terraform version to 1.4.6 - Wojciech Zagrajczuk (daac16b)
* DXE-2847 Freeze cli-cloudlets and cli-onboard version until further notice - Wojciech Zagrajczuk
* DXE-2847 Upgrade akamai terraform provider to v5.0.1 - Wojciech Zagrajczuk (1108315)

## v2.13.0 (2023-06-02)

* DXE-1338 Upgrade akamai terraform provider to v4.1.0 - Darek Stopka (82e3518)
* DXE-2093 Update terraform version - Mateusz Jakubiec (9445045)

## v2.12.1 (2023-04-28)

* DXE-2519 Fix for building "purge" and "sandbox" images - Michal Wojcik

## v2.12.0 (2023-04-27)

* DXE-2519 Upgrade akamai terraform provider to v3.6.0 - Michal Wojcik (d6b8744e)

## v2.11.0 (2023-04-03)

* DXE-2352 Upgrade akamai terraform provider to v3.5.0 - Piyush Kaushik (9346ac8)

## v2.10.0 (2023-03-06)

* DXE-2341 Upgrade akamai terraform provider to v3.4.0 - Wojciech Zagrajczuk (7ed8f82)

## v2.9.0 (2023-02-02)

* DXE-2170 Upgrade akamai terraform provider to v3.3.0 - Michal Wojcik (97d48b5) 

## v2.8.1 (2022-12-19)

* DXE-1948 Upgrade akamai terraform provider to v3.2.1 - Mateusz Jakubiec (b8f4d30) 

## v2.8.0 (2022-12-15)

* DXE-1836 Upgrade akamai terraform provider to v3.2.0 - Mateusz Jakubiec (b87cc470) 

## v2.7.0 (2022-12-05)

* DXE-1817 Upgrade akamai terraform provider to v3.1.0 - Wojciech Zagrajczuk (6362202)

## v2.6.0 (2022-10-28)

* DXE-1727 Upgrade akamai terraform provider to v3.0.0 - Michal Wojcik (2152720d)

## v2.5.0 (2022-10-20)

* DXE-1338 Upgrade akamai terraform provider to v2.4.2 - Darek Stopka (0a15b65)
* DXE-1504 move from travis-ci to github actions - Mateusz Jakubiec (31f06b8)
* DXE-1339 Support Mac M1 in docker - Dawid Dzhafarov (667907c)
* DXE-1260 upgrade terraform - López López, Roberto (428c691)
* DXE-1260 upgrade terraform - López López, Roberto (57321a0)
* DXE-727 update dockerfiles for CLI 1.4.0 - López López, Roberto (ca83063)
* DXE-727 update dockerfiles for CLI 1.4.0 - López López, Roberto (b18e7f9)
* updated Readme doc - baskaran (83b065c)
* updated Readme and cli sanity test - baskaran (d1a4988)
* Akamai gtm cli docker files - baskaran (9e59ec2)

## v2.4.0 (2021-12-28)

* feat: akamai gtm cli docker files (#66) - baskaran (e1737b6)
* fix: update comments to match build logic - Anthony Hogg (480629f)
* fix: do not tag cron builds - Anthony Hogg (d105bcd)


## v2.3.2 (2021-09-01)

* fix: tag the current commit, not the changelog commit - Anthony Hogg (3992eb3)


## v2.3.1 (2021-09-01)

* chore: upgrade to alpine 3.13 (#48) - Anthony Hogg (1614368)


## v2.3.0 (2021-08-30)

* all-access /cli and /workdir to avoid jenkins perm issues (refs #38) - Anthony Hogg (5c69e01)


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


## v2.2.1 ()

chore: update changelog (nochangelog) [ci skip]


