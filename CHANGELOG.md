<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v2.3.2](https://github.com/puppetlabs/puppet_litmus/tree/v2.3.2) - 2025-08-13

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v2.3.1...v2.3.2)

### Fixed

- (MAINT) Fix Rocky typo in matrix.json [#602](https://github.com/puppetlabs/puppet_litmus/pull/602) ([LukasAud](https://github.com/LukasAud))

## [v2.3.1](https://github.com/puppetlabs/puppet_litmus/tree/v2.3.1) - 2025-08-13

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v2.3.0...v2.3.1)

### Fixed

- (CAT-2427) Address 9th gen auth failures [#600](https://github.com/puppetlabs/puppet_litmus/pull/600) ([LukasAud](https://github.com/LukasAud))

## [v2.3.0](https://github.com/puppetlabs/puppet_litmus/tree/v2.3.0) - 2025-08-06

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v2.2.1...v2.3.0)

### Added

- (CAT-2433) Adds option to return latest agent build [#596](https://github.com/puppetlabs/puppet_litmus/pull/596) ([david22swan](https://github.com/david22swan))

## [v2.2.1](https://github.com/puppetlabs/puppet_litmus/tree/v2.2.1) - 2025-08-06

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v2.2.0...v2.2.1)

### Fixed

- (CAT-2416) Address almalinux 8 provisioning issues [#597](https://github.com/puppetlabs/puppet_litmus/pull/597) ([LukasAud](https://github.com/LukasAud))

## [v2.2.0](https://github.com/puppetlabs/puppet_litmus/tree/v2.2.0) - 2025-07-30

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v2.1.0...v2.2.0)

### Added

- (FEAT) Set nightly puppetcore builds as an option rather than default [#594](https://github.com/puppetlabs/puppet_litmus/pull/594) ([david22swan](https://github.com/david22swan))

## [v2.1.0](https://github.com/puppetlabs/puppet_litmus/tree/v2.1.0) - 2025-07-29

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v2.0.0...v2.1.0)

### Added

- (FEAT) Update matrix_from_metadata_v3 to target puppetcore nightly [#592](https://github.com/puppetlabs/puppet_litmus/pull/592) ([david22swan](https://github.com/david22swan))
- (PA-7608) Use artifactory URL for puppetcore nightlies [#591](https://github.com/puppetlabs/puppet_litmus/pull/591) ([skyamgarp](https://github.com/skyamgarp))

## [v2.0.0](https://github.com/puppetlabs/puppet_litmus/tree/v2.0.0) - 2025-05-06

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.6.1...v2.0.0)

### Changed

- feat: use puppetcore by default in matrix_from_metadata [#586](https://github.com/puppetlabs/puppet_litmus/pull/586) ([jordanbreen28](https://github.com/jordanbreen28))
- breaking: mark matrix_from_metadata_v2 as deprecated in output [#584](https://github.com/puppetlabs/puppet_litmus/pull/584) ([jordanbreen28](https://github.com/jordanbreen28))
- breaking: remove deprecated matrix_from_metadata (v1) [#583](https://github.com/puppetlabs/puppet_litmus/pull/583) ([jordanbreen28](https://github.com/jordanbreen28))
- (CAT-2286) Remove Ruby 2.x/Puppet 7.x Support [#581](https://github.com/puppetlabs/puppet_litmus/pull/581) ([LukasAud](https://github.com/LukasAud))

### Added

- feat: add puppetcore agent installation support [#585](https://github.com/puppetlabs/puppet_litmus/pull/585) ([jordanbreen28](https://github.com/jordanbreen28))

## [v1.6.1](https://github.com/puppetlabs/puppet_litmus/tree/v1.6.1) - 2024-12-11

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.6.0...v1.6.1)

### Fixed

- Update to bolt 4 [#579](https://github.com/puppetlabs/puppet_litmus/pull/579) ([gavindidrichsen](https://github.com/gavindidrichsen))

## [v1.6.0](https://github.com/puppetlabs/puppet_litmus/tree/v1.6.0) - 2024-10-28

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.5.1...v1.6.0)

### Added

- (feat) - Add Ubuntu-24.04 to matrix_from_metadata v2 and v3 [#577](https://github.com/puppetlabs/puppet_litmus/pull/577) ([shubhamshinde360](https://github.com/shubhamshinde360))
- (FEAT) Add PE to matrix_from_metadata_v3 [#576](https://github.com/puppetlabs/puppet_litmus/pull/576) ([coreymbe](https://github.com/coreymbe))

## [v1.5.1](https://github.com/puppetlabs/puppet_litmus/tree/v1.5.1) - 2024-10-03

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.5.0...v1.5.1)

### Fixed

- (CAT-2052) Pass target container URI instead of container SHA ID to add_feature_to_node() method [#574](https://github.com/puppetlabs/puppet_litmus/pull/574) ([shubhamshinde360](https://github.com/shubhamshinde360))

## [v1.5.0](https://github.com/puppetlabs/puppet_litmus/tree/v1.5.0) - 2024-08-05

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.4.0...v1.5.0)

### Added

- (FEAT) - Add debian 12 & alma/centos/rocky 9 to matrix_from_metadata v2 & v3 [#572](https://github.com/puppetlabs/puppet_litmus/pull/572) ([jordanbreen28](https://github.com/jordanbreen28))
- automatically filter provision_service from matrix [#563](https://github.com/puppetlabs/puppet_litmus/pull/563) ([h0tw1r3](https://github.com/h0tw1r3))
- pass full inventory path to task [#552](https://github.com/puppetlabs/puppet_litmus/pull/552) ([h0tw1r3](https://github.com/h0tw1r3))
- (feature) matrix from metadata v3 [#549](https://github.com/puppetlabs/puppet_litmus/pull/549) ([h0tw1r3](https://github.com/h0tw1r3))
- lxd provisioner support [#544](https://github.com/puppetlabs/puppet_litmus/pull/544) ([h0tw1r3](https://github.com/h0tw1r3))

## [v1.4.0](https://github.com/puppetlabs/puppet_litmus/tree/v1.4.0) - 2024-05-01

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.3.0...v1.4.0)

### Added

- add amazonlinux litmus images to matrix [#560](https://github.com/puppetlabs/puppet_litmus/pull/560) ([h0tw1r3](https://github.com/h0tw1r3))
- add supported docker el9 platforms to matrix [#551](https://github.com/puppetlabs/puppet_litmus/pull/551) ([h0tw1r3](https://github.com/h0tw1r3))
- (maint) add oracle linux 8 [#546](https://github.com/puppetlabs/puppet_litmus/pull/546) ([h0tw1r3](https://github.com/h0tw1r3))

### Fixed

- use dockercli specinfra backend for docker_nodes [#559](https://github.com/puppetlabs/puppet_litmus/pull/559) ([h0tw1r3](https://github.com/h0tw1r3))
- drop Debian 9 stretch from matrix [#556](https://github.com/puppetlabs/puppet_litmus/pull/556) ([h0tw1r3](https://github.com/h0tw1r3))
- (BUGFIX) Remove Oracle/Scientific Linux 6 from `matrix_from_metadata_v2` [#555](https://github.com/puppetlabs/puppet_litmus/pull/555) ([david22swan](https://github.com/david22swan))
- (BUGFIX) Remove CentOS 6 from `matrix_from_metadata` [#553](https://github.com/puppetlabs/puppet_litmus/pull/553) ([david22swan](https://github.com/david22swan))
- Minor install_module improvements [#550](https://github.com/puppetlabs/puppet_litmus/pull/550) ([h0tw1r3](https://github.com/h0tw1r3))
- (CAT-1688) - Pin rubocop to `~> 1.50.0` [#541](https://github.com/puppetlabs/puppet_litmus/pull/541) ([LukasAud](https://github.com/LukasAud))

## [v1.3.0](https://github.com/puppetlabs/puppet_litmus/tree/v1.3.0) - 2023-12-21

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.2.1...v1.3.0)

### Added

- (CAT-1522) - Adding support for Ubuntu 22.04 ARM OS [#537](https://github.com/puppetlabs/puppet_litmus/pull/537) ([Ramesh7](https://github.com/Ramesh7))

## [v1.2.1](https://github.com/puppetlabs/puppet_litmus/tree/v1.2.1) - 2023-11-10

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.2.0...v1.2.1)

### Fixed

- (CAT-1545) - Return RHEL-9 ARM images in matrix [#532](https://github.com/puppetlabs/puppet_litmus/pull/532) ([jordanbreen28](https://github.com/jordanbreen28))

## [v1.2.0](https://github.com/puppetlabs/puppet_litmus/tree/v1.2.0) - 2023-10-25

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.1.3...v1.2.0)

### Added

- (CAT-1521) - Adding new OS RHEL-9 ARM [#530](https://github.com/puppetlabs/puppet_litmus/pull/530) ([Ramesh7](https://github.com/Ramesh7))
- (CAT-1287) - Adding Debian 12 docker for Compatibility testing [#523](https://github.com/puppetlabs/puppet_litmus/pull/523) ([Ramesh7](https://github.com/Ramesh7))

## [v1.1.3](https://github.com/puppetlabs/puppet_litmus/tree/v1.1.3) - 2023-07-31

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.1.2...v1.1.3)

### Fixed

- (CAT-1265) - Fix agent install on vagrant boxes [#518](https://github.com/puppetlabs/puppet_litmus/pull/518) ([jordanbreen28](https://github.com/jordanbreen28))

## [v1.1.2](https://github.com/puppetlabs/puppet_litmus/tree/v1.1.2) - 2023-07-28

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.1.1...v1.1.2)

### Fixed

- (CAT-1241) - Adding retry when provision failed with Timeout [#516](https://github.com/puppetlabs/puppet_litmus/pull/516) ([Ramesh7](https://github.com/Ramesh7))

## [v1.1.1](https://github.com/puppetlabs/puppet_litmus/tree/v1.1.1) - 2023-07-27

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.1.0...v1.1.1)

### Fixed

- (CAT-1249) - Fix Spinner on Windows Hosts [#514](https://github.com/puppetlabs/puppet_litmus/pull/514) ([jordanbreen28](https://github.com/jordanbreen28))
- (CONT-1243) - Skip tear_down if no provisioner found [#512](https://github.com/puppetlabs/puppet_litmus/pull/512) ([jordanbreen28](https://github.com/jordanbreen28))

## [v1.1.0](https://github.com/puppetlabs/puppet_litmus/tree/v1.1.0) - 2023-07-06

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.0.3...v1.1.0)

### Added

- (FEAT) - Add ability to supply a custom matrix and override default provisioner [#506](https://github.com/puppetlabs/puppet_litmus/pull/506) ([jordanbreen28](https://github.com/jordanbreen28))

## [v1.0.3](https://github.com/puppetlabs/puppet_litmus/tree/v1.0.3) - 2023-05-04

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.0.2...v1.0.3)

### Fixed

- (CONT-933) Remove Honeycomb [#498](https://github.com/puppetlabs/puppet_litmus/pull/498) ([david22swan](https://github.com/david22swan))

## [v1.0.2](https://github.com/puppetlabs/puppet_litmus/tree/v1.0.2) - 2023-04-25

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.0.1...v1.0.2)

### Fixed

- (MAINT) Force newer Puppet 7 Gem [#496](https://github.com/puppetlabs/puppet_litmus/pull/496) ([chelnak](https://github.com/chelnak))

## [v1.0.1](https://github.com/puppetlabs/puppet_litmus/tree/v1.0.1) - 2023-04-25

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.0.0...v1.0.1)

### Fixed

- (MAINT) Bump modulebuilder dependency [#494](https://github.com/puppetlabs/puppet_litmus/pull/494) ([chelnak](https://github.com/chelnak))

## [v1.0.0](https://github.com/puppetlabs/puppet_litmus/tree/v1.0.0) - 2023-04-25

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v1.0.0.rc.1...v1.0.0)

## [v1.0.0.rc.1](https://github.com/puppetlabs/puppet_litmus/tree/v1.0.0.rc.1) - 2023-04-19

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.36.1...v1.0.0.rc.1)

### Changed

- (CONT-806) Add Ruby 3.2 support [#485](https://github.com/puppetlabs/puppet_litmus/pull/485) ([GSPatton](https://github.com/GSPatton))

### Added

- (CONT-806) Ruby 3 / Puppet 8 additions [#491](https://github.com/puppetlabs/puppet_litmus/pull/491) ([chelnak](https://github.com/chelnak))

## [v0.36.1](https://github.com/puppetlabs/puppet_litmus/tree/v0.36.1) - 2023-03-28

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.36.0...v0.36.1)

### Fixed

- (CONT-828) Unpin r10k [#482](https://github.com/puppetlabs/puppet_litmus/pull/482) ([david22swan](https://github.com/david22swan))
- (CONT-827) Patch Puppet 8 to take from Github [#481](https://github.com/puppetlabs/puppet_litmus/pull/481) ([david22swan](https://github.com/david22swan))

## [v0.36.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.36.0) - 2023-03-27

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.34.6...v0.36.0)

### Added

- (CONT-764) Update matrix_from_metadata_v2 [#478](https://github.com/puppetlabs/puppet_litmus/pull/478) ([chelnak](https://github.com/chelnak))

### Fixed

- (maint) Return Puppet 6 to matrix_from_metadata_v2 [#479](https://github.com/puppetlabs/puppet_litmus/pull/479) ([david22swan](https://github.com/david22swan))
- (CONT-404) Address deprecation warnings [#477](https://github.com/puppetlabs/puppet_litmus/pull/477) ([LukasAud](https://github.com/LukasAud))

## [v0.34.6](https://github.com/puppetlabs/puppet_litmus/tree/v0.34.6) - 2023-03-09

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.34.5...v0.34.6)

### Fixed

- (CONT-712) Pin r10k gem [#471](https://github.com/puppetlabs/puppet_litmus/pull/471) ([chelnak](https://github.com/chelnak))

## [v0.34.5](https://github.com/puppetlabs/puppet_litmus/tree/v0.34.5) - 2023-02-27

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.34.4...v0.34.5)

### Fixed

- (maint) - Update windows 2019 image [#468](https://github.com/puppetlabs/puppet_litmus/pull/468) ([jordanbreen28](https://github.com/jordanbreen28))

## [0.34.4](https://github.com/puppetlabs/puppet_litmus/tree/0.34.4) - 2022-11-23

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.34.2...0.34.4)

### Fixed

- (MAINT) Remove Windows Server 2012R2 [#462](https://github.com/puppetlabs/puppet_litmus/pull/462) ([chelnak](https://github.com/chelnak))

## [0.34.2](https://github.com/puppetlabs/puppet_litmus/tree/0.34.2) - 2022-10-12

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.34.3...0.34.2)

## [0.34.3](https://github.com/puppetlabs/puppet_litmus/tree/0.34.3) - 2022-10-12

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.34.1...0.34.3)

### Fixed

- (CONT-193) Always build parallel task [#459](https://github.com/puppetlabs/puppet_litmus/pull/459) ([chelnak](https://github.com/chelnak))

### Other

- (maint) Release prep v0.34.3 [#461](https://github.com/puppetlabs/puppet_litmus/pull/461) ([david22swan](https://github.com/david22swan))

## [v0.34.1](https://github.com/puppetlabs/puppet_litmus/tree/v0.34.1) - 2022-08-10

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.34.0...v0.34.1)

## [v0.34.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.34.0) - 2022-08-10

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.33.2...v0.34.0)

### Added

- (GH-cat-12) Add RedHat 9 to `extract_matrix_from_metadata_v2` [#454](https://github.com/puppetlabs/puppet_litmus/pull/454) ([david22swan](https://github.com/david22swan))

### Fixed

- Update bolt version requirement [#456](https://github.com/puppetlabs/puppet_litmus/pull/456) ([chelnak](https://github.com/chelnak))

## [v0.33.2](https://github.com/puppetlabs/puppet_litmus/tree/v0.33.2) - 2022-04-04

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.33.1...v0.33.2)

## [v0.33.1](https://github.com/puppetlabs/puppet_litmus/tree/v0.33.1) - 2022-04-04

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.33.0...v0.33.1)

## [v0.33.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.33.0) - 2022-04-04

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.32.0...v0.33.0)

### Added

- (GH-cat-11) Add Ubuntu 22.04 to matrix_from_metadata_v2 [#444](https://github.com/puppetlabs/puppet_litmus/pull/444) ([david22swan](https://github.com/david22swan))

### Fixed

- (GH-cat-8) CentOS Stream8 will no longer be changed in the metadata [#450](https://github.com/puppetlabs/puppet_litmus/pull/450) ([david22swan](https://github.com/david22swan))
- (GH-cat-8) Move CentOS 8 support to CentOS Stream 8 [#446](https://github.com/puppetlabs/puppet_litmus/pull/446) ([david22swan](https://github.com/david22swan))

## [v0.32.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.32.0) - 2022-02-28

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.31.1...v0.32.0)

### Added

- (FM-8922) Re-enable support for Windows 2022 [#439](https://github.com/puppetlabs/puppet_litmus/pull/439) ([david22swan](https://github.com/david22swan))

## [v0.31.1](https://github.com/puppetlabs/puppet_litmus/tree/v0.31.1) - 2022-02-07

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.31.0...v0.31.1)

## [v0.31.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.31.0) - 2022-02-07

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.30.0...v0.31.0)

### Added

- (FM-8922) Add Support for Windows 2022 [#435](https://github.com/puppetlabs/puppet_litmus/pull/435) ([david22swan](https://github.com/david22swan))

### Fixed

- (FM-8922) Disable Support for Windows 2022 [#437](https://github.com/puppetlabs/puppet_litmus/pull/437) ([david22swan](https://github.com/david22swan))
- Allow Litmus Functions to accept a target [#427](https://github.com/puppetlabs/puppet_litmus/pull/427) ([RandomNoun7](https://github.com/RandomNoun7))

## [v0.30.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.30.0) - 2021-09-28

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.29.0...v0.30.0)

### Added

- (IAC-1751/IAC-1752) Add support for Rocky and AlmaLinux 8 to `extract_matrix_from_metadate_v2` [#431](https://github.com/puppetlabs/puppet_litmus/pull/431) ([david22swan](https://github.com/david22swan))

### Fixed

- (IAC-1751) Fix for Rocky 8 [#432](https://github.com/puppetlabs/puppet_litmus/pull/432) ([david22swan](https://github.com/david22swan))

## [v0.29.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.29.0) - 2021-09-06

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.28.0...v0.29.0)

### Added

- [IAC-1738] - allow matrix_from_metadata_v2 to exclude platforms from GA matrix [#426](https://github.com/puppetlabs/puppet_litmus/pull/426) ([adrianiurca](https://github.com/adrianiurca))

### Fixed

- Added options to idempotent_apply [#425](https://github.com/puppetlabs/puppet_litmus/pull/425) ([ZloeSabo](https://github.com/ZloeSabo))

## [v0.28.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.28.0) - 2021-07-29

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.27.0...v0.28.0)

### Added

- (IAC-1710) - Add Debian 11 Bullseye to `matrix_from_metadata_v2` [#423](https://github.com/puppetlabs/puppet_litmus/pull/423) ([david22swan](https://github.com/david22swan))

### Fixed

- (maint) - Increase the connection timeout limit [#414](https://github.com/puppetlabs/puppet_litmus/pull/414) ([david22swan](https://github.com/david22swan))

## [v0.27.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.27.0) - 2021-04-19

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.26.3...v0.27.0)

### Added

- (maint) Update bolt requirement to include 3.x [#407](https://github.com/puppetlabs/puppet_litmus/pull/407) ([beechtom](https://github.com/beechtom))

## [v0.26.3](https://github.com/puppetlabs/puppet_litmus/tree/v0.26.3) - 2021-04-13

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.26.2...v0.26.3)

### Fixed

- (bug) update the default inventory.yaml file location in rake_tasks [#405](https://github.com/puppetlabs/puppet_litmus/pull/405) ([sheenaajay](https://github.com/sheenaajay))

## [v0.26.2](https://github.com/puppetlabs/puppet_litmus/tree/v0.26.2) - 2021-04-12

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.26.1...v0.26.2)

### Fixed

- (bugfix) Update inventory path [#403](https://github.com/puppetlabs/puppet_litmus/pull/403) ([pmcmaw](https://github.com/pmcmaw))

## [v0.26.1](https://github.com/puppetlabs/puppet_litmus/tree/v0.26.1) - 2021-04-12

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.26.0...v0.26.1)

### Fixed

- (GH-380) Moving inventory.yaml to /spec/fixtures/litmus_inventory.yaml [#396](https://github.com/puppetlabs/puppet_litmus/pull/396) ([pmcmaw](https://github.com/pmcmaw))

## [v0.26.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.26.0) - 2021-03-10

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.25.1...v0.26.0)

### Added

- (IAC-1307) Generate spec test matrix [#395](https://github.com/puppetlabs/puppet_litmus/pull/395) ([sanfrancrisko](https://github.com/sanfrancrisko))

### Fixed

- (IAC-1420) Enforce UTF-8 when running puppet on the test target [#397](https://github.com/puppetlabs/puppet_litmus/pull/397) ([david22swan](https://github.com/david22swan))

## [v0.25.1](https://github.com/puppetlabs/puppet_litmus/tree/v0.25.1) - 2021-02-26

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.25.0...v0.25.1)

### Fixed

- Disable testing on docker containers for Debian 8 and Ubuntu 14.04 [#391](https://github.com/puppetlabs/puppet_litmus/pull/391) ([carabasdaniel](https://github.com/carabasdaniel))

## [v0.25.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.25.0) - 2021-02-25

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.24.0...v0.25.0)

### Added

- Add docker images to matrix from metadata v2 [#385](https://github.com/puppetlabs/puppet_litmus/pull/385) ([carabasdaniel](https://github.com/carabasdaniel))

## [v0.24.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.24.0) - 2021-02-15

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.23.1...v0.24.0)

### Changed

- Remove puppet5 from matrix_from_metadata script and update puppet6 and puppet7 versions [#386](https://github.com/puppetlabs/puppet_litmus/pull/386) ([carabasdaniel](https://github.com/carabasdaniel))

## [v0.23.1](https://github.com/puppetlabs/puppet_litmus/tree/v0.23.1) - 2021-02-08

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.23.0...v0.23.1)

### Fixed

- Ensure that first-order failures in idempotent_apply get reported [#383](https://github.com/puppetlabs/puppet_litmus/pull/383) ([DavidS](https://github.com/DavidS))

## [v0.23.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.23.0) - 2021-02-01

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.22.0...v0.23.0)

## [v0.22.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.22.0) - 2021-02-01

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.21.0...v0.22.0)

### Added

- Use puppet 6 nightlies and increase timeout limit [#373](https://github.com/puppetlabs/puppet_litmus/pull/373) ([carabasdaniel](https://github.com/carabasdaniel))
- Remove rhel6 from all tests [#352](https://github.com/puppetlabs/puppet_litmus/pull/352) ([DavidS](https://github.com/DavidS))

### Fixed

- Isolate puppet_helpers workaround for windows os family [#379](https://github.com/puppetlabs/puppet_litmus/pull/379) ([carabasdaniel](https://github.com/carabasdaniel))
- Remove deprecated version from bolt inventory [#376](https://github.com/puppetlabs/puppet_litmus/pull/376) ([nmaludy](https://github.com/nmaludy))
- (IAC-1365) - Workaround bolt/windows/exitcode bug [#371](https://github.com/puppetlabs/puppet_litmus/pull/371) ([david22swan](https://github.com/david22swan))

## [v0.21.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.21.0) - 2021-01-12

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.20.0...v0.21.0)

### Added

- (CISC-972) allow parallel provisioning of systems [#359](https://github.com/puppetlabs/puppet_litmus/pull/359) ([tphoney](https://github.com/tphoney))
- Add dynamic agent collections to test matrix generation [#357](https://github.com/puppetlabs/puppet_litmus/pull/357) ([DavidS](https://github.com/DavidS))
- Update honeycomb trace ENV var to new name [#355](https://github.com/puppetlabs/puppet_litmus/pull/355) ([DavidS](https://github.com/DavidS))

### Fixed

- (IAC-1287) Only log transient provisioning errors in debug mode [#367](https://github.com/puppetlabs/puppet_litmus/pull/367) ([DavidS](https://github.com/DavidS))
- Remove optional parameter append_cli from provision api [#362](https://github.com/puppetlabs/puppet_litmus/pull/362) ([hajee](https://github.com/hajee))
- honeycomb: Improve capturing exitstatus in the process_span [#354](https://github.com/puppetlabs/puppet_litmus/pull/354) ([DavidS](https://github.com/DavidS))
- Capture the full bolt results after provisioning [#353](https://github.com/puppetlabs/puppet_litmus/pull/353) ([DavidS](https://github.com/DavidS))
- Fix append_cli parameters [#344](https://github.com/puppetlabs/puppet_litmus/pull/344) ([hajee](https://github.com/hajee))

## [v0.20.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.20.0) - 2020-11-26

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.19.0...v0.20.0)

### Added

- Check connectivity after provision [#345](https://github.com/puppetlabs/puppet_litmus/pull/345) ([DavidS](https://github.com/DavidS))

### Fixed

- Remove debugging output [#347](https://github.com/puppetlabs/puppet_litmus/pull/347) ([DavidS](https://github.com/DavidS))

## [v0.19.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.19.0) - 2020-11-23

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.18.4...v0.19.0)

### Added

- Calculate github actions job matrix from metadata.json; fix frozen-string modification in puppet_output [#327](https://github.com/puppetlabs/puppet_litmus/pull/327) ([DavidS](https://github.com/DavidS))
- Add write_file helper [#324](https://github.com/puppetlabs/puppet_litmus/pull/324) ([RandomNoun7](https://github.com/RandomNoun7))
- (IAC-1094) add option to filter testcase execution based on tags [#320](https://github.com/puppetlabs/puppet_litmus/pull/320) ([sheenaajay](https://github.com/sheenaajay))
- Allow acceptance tests to be run as sudo user [#319](https://github.com/puppetlabs/puppet_litmus/pull/319) ([carabasdaniel](https://github.com/carabasdaniel))

### Fixed

- Show successful agent result when DEBUG env true [#341](https://github.com/puppetlabs/puppet_litmus/pull/341) ([carabasdaniel](https://github.com/carabasdaniel))
- Try to fix the path on puppet version failure [#338](https://github.com/puppetlabs/puppet_litmus/pull/338) ([carabasdaniel](https://github.com/carabasdaniel))
- (GH-326) - Return node name when testing is complete [#336](https://github.com/puppetlabs/puppet_litmus/pull/336) ([pmcmaw](https://github.com/pmcmaw))
- Use default windows-2016 server image [#335](https://github.com/puppetlabs/puppet_litmus/pull/335) ([carabasdaniel](https://github.com/carabasdaniel))
- Increase retry count after agent installation [#334](https://github.com/puppetlabs/puppet_litmus/pull/334) ([carabasdaniel](https://github.com/carabasdaniel))
- Add validation check after agent install [#332](https://github.com/puppetlabs/puppet_litmus/pull/332) ([carabasdaniel](https://github.com/carabasdaniel))
- simplify GCP images to use family names [#330](https://github.com/puppetlabs/puppet_litmus/pull/330) ([DavidS](https://github.com/DavidS))
- Add optional ignore_dependencies parameter to install_module function [#318](https://github.com/puppetlabs/puppet_litmus/pull/318) ([alanfryer](https://github.com/alanfryer))

## [v0.18.4](https://github.com/puppetlabs/puppet_litmus/tree/v0.18.4) - 2020-07-01

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.18.3...v0.18.4)

### Fixed

- (IAC-896) - Revert "(IAC-825) - Adding net-ssh 5 dependent gems" [#313](https://github.com/puppetlabs/puppet_litmus/pull/313) ([pmcmaw](https://github.com/pmcmaw))
- Protect version reporting from undefined-ness [#312](https://github.com/puppetlabs/puppet_litmus/pull/312) ([DavidS](https://github.com/DavidS))
- Ignore stderr of serverspec commands by setting request_pty to false [#309](https://github.com/puppetlabs/puppet_litmus/pull/309) ([lswith](https://github.com/lswith))

## [v0.18.3](https://github.com/puppetlabs/puppet_litmus/tree/v0.18.3) - 2020-06-10

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.18.2...v0.18.3)

### Fixed

- Improve bolt error formatting [#307](https://github.com/puppetlabs/puppet_litmus/pull/307) ([DavidS](https://github.com/DavidS))
- install_module: update module_repository default use to puppet's default [#305](https://github.com/puppetlabs/puppet_litmus/pull/305) ([DavidS](https://github.com/DavidS))
- Improve diagnostics output [#304](https://github.com/puppetlabs/puppet_litmus/pull/304) ([DavidS](https://github.com/DavidS))
- Copy-edit docs strings for consistency and accuracy [#302](https://github.com/puppetlabs/puppet_litmus/pull/302) ([DavidS](https://github.com/DavidS))
- Fix install_modules_from_directory symlink handling [#301](https://github.com/puppetlabs/puppet_litmus/pull/301) ([DavidS](https://github.com/DavidS))
- Update wiki links to new docs site [#299](https://github.com/puppetlabs/puppet_litmus/pull/299) ([DavidS](https://github.com/DavidS))

## [v0.18.2](https://github.com/puppetlabs/puppet_litmus/tree/v0.18.2) - 2020-05-28

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.18.1...v0.18.2)

### Fixed

- (IAC-825) - Adding net-ssh 5 dependent gems [#297](https://github.com/puppetlabs/puppet_litmus/pull/297) ([pmcmaw](https://github.com/pmcmaw))
- Use default working directory for all uploads to SUTs [#296](https://github.com/puppetlabs/puppet_litmus/pull/296) ([DavidS](https://github.com/DavidS))
- Log the filename instead of the file object when install fails [#294](https://github.com/puppetlabs/puppet_litmus/pull/294) ([mmarod](https://github.com/mmarod))
- Catch more errors in rake_helpers [#286](https://github.com/puppetlabs/puppet_litmus/pull/286) ([DavidS](https://github.com/DavidS))

## [v0.18.1](https://github.com/puppetlabs/puppet_litmus/tree/v0.18.1) - 2020-04-02

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.18.0...v0.18.1)

### Fixed

- fix linking honeycomb spans across processes; avoid double send on forks [#282](https://github.com/puppetlabs/puppet_litmus/pull/282) ([DavidS](https://github.com/DavidS))
- Fixes `undefined method facts_from_node` error from 0.18.0 [#281](https://github.com/puppetlabs/puppet_litmus/pull/281) ([DavidS](https://github.com/DavidS))

## [v0.18.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.18.0) - 2020-03-31

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/v0.17.0...v0.18.0)

### Added

- move to using bolt v2 [#254](https://github.com/puppetlabs/puppet_litmus/pull/254) ([tphoney](https://github.com/tphoney))

### Fixed

- Use 'target' instead of 'node' in bolt result hashes [#279](https://github.com/puppetlabs/puppet_litmus/pull/279) ([DavidS](https://github.com/DavidS))
- (DOCS) README edit pass [#278](https://github.com/puppetlabs/puppet_litmus/pull/278) ([clairecadman](https://github.com/clairecadman))
- (IAC-187) force installing modules [#275](https://github.com/puppetlabs/puppet_litmus/pull/275) ([DavidS](https://github.com/DavidS))
- Add `--trace` by default to all `puppet apply` commands [#274](https://github.com/puppetlabs/puppet_litmus/pull/274) ([DavidS](https://github.com/DavidS))
- Fix missing require in `litmus:tear_down` [#273](https://github.com/puppetlabs/puppet_litmus/pull/273) ([DavidS](https://github.com/DavidS))
- (IAC-658) suppress libhoney warning [#272](https://github.com/puppetlabs/puppet_litmus/pull/272) ([DavidS](https://github.com/DavidS))
- (IAC-660) make the platform fact optional [#271](https://github.com/puppetlabs/puppet_litmus/pull/271) ([DavidS](https://github.com/DavidS))
- Improve rake task install_module and install_modules_from_directory [#247](https://github.com/puppetlabs/puppet_litmus/pull/247) ([findmyname666](https://github.com/findmyname666))

## [v0.17.0](https://github.com/puppetlabs/puppet_litmus/tree/v0.17.0) - 2020-03-24

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.16.0...v0.17.0)

### Added

- (IAC-373) link spans to an existing trace using HTTP_X_HONEYCOMB_TRACE [#265](https://github.com/puppetlabs/puppet_litmus/pull/265) ([DavidS](https://github.com/DavidS))
- (IAC-537) capture more info for honeycomb [#264](https://github.com/puppetlabs/puppet_litmus/pull/264) ([DavidS](https://github.com/DavidS))

## [0.16.0](https://github.com/puppetlabs/puppet_litmus/tree/0.16.0) - 2020-03-12

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.15.0...0.16.0)

### Added

- (MAINT) Add interpolate_powershell helper method [#244](https://github.com/puppetlabs/puppet_litmus/pull/244) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (IAC-536) Unify honeycomb field names; fallback for branch builds [#243](https://github.com/puppetlabs/puppet_litmus/pull/243) ([DavidS](https://github.com/DavidS))
- (IAC-490) Add CI checks and metadata information of github action [#241](https://github.com/puppetlabs/puppet_litmus/pull/241) ([sheenaajay](https://github.com/sheenaajay))

### Fixed

- Make InventoryManipulation available to all rake tasks [#251](https://github.com/puppetlabs/puppet_litmus/pull/251) ([DavidS](https://github.com/DavidS))
- (GH-246) Fix install_modules_from_directory logic [#248](https://github.com/puppetlabs/puppet_litmus/pull/248) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (GH-234) Remove PDK dependency [#235](https://github.com/puppetlabs/puppet_litmus/pull/235) ([glennsarti](https://github.com/glennsarti))

## [0.15.0](https://github.com/puppetlabs/puppet_litmus/tree/0.15.0) - 2020-02-03

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.14.0...0.15.0)

## [0.14.0](https://github.com/puppetlabs/puppet_litmus/tree/0.14.0) - 2020-02-03

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.13.1...0.14.0)

### Changed

- (feat) move to v2 of bolt inventory file [#233](https://github.com/puppetlabs/puppet_litmus/pull/233) ([tphoney](https://github.com/tphoney))

### Added

- (MODULES-10478) honeycomb integration to litmus [#238](https://github.com/puppetlabs/puppet_litmus/pull/238) ([sheenaajay](https://github.com/sheenaajay))
- (feat) - new rake task to add a given feature to a group of nodes [#236](https://github.com/puppetlabs/puppet_litmus/pull/236) ([david22swan](https://github.com/david22swan))
- (feat) check connectivity status, after testing completes [#231](https://github.com/puppetlabs/puppet_litmus/pull/231) ([tphoney](https://github.com/tphoney))
- (feat) new rake task to check nodes are available [#230](https://github.com/puppetlabs/puppet_litmus/pull/230) ([tphoney](https://github.com/tphoney))
- (MAINT) Ensure acceptance:localhost task also runs spec_prep [#206](https://github.com/puppetlabs/puppet_litmus/pull/206) ([RandomNoun7](https://github.com/RandomNoun7))

### Fixed

- Improve error reporting [#228](https://github.com/puppetlabs/puppet_litmus/pull/228) ([DavidS](https://github.com/DavidS))
- (MODULES-10018) Extend RSpec config with PuppetLitmus [#226](https://github.com/puppetlabs/puppet_litmus/pull/226) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (MODULES-10115) Fix Windows endpoint declaration when using TARGET_HOST [#224](https://github.com/puppetlabs/puppet_litmus/pull/224) ([michaeltlombardi](https://github.com/michaeltlombardi))

## [0.13.1](https://github.com/puppetlabs/puppet_litmus/tree/0.13.1) - 2019-12-11

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.13.0...0.13.1)

### Fixed

- (FM-8772) Fix install_agent error output message [#221](https://github.com/puppetlabs/puppet_litmus/pull/221) ([florindragos](https://github.com/florindragos))

## [0.13.0](https://github.com/puppetlabs/puppet_litmus/tree/0.13.0) - 2019-12-04

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.12.0...0.13.0)

### Added

- (FM-8355) Add spec_helper_acceptance [#210](https://github.com/puppetlabs/puppet_litmus/pull/210) ([florindragos](https://github.com/florindragos))
- (FM-8611) Reinstall module [#209](https://github.com/puppetlabs/puppet_litmus/pull/209) ([florindragos](https://github.com/florindragos))

### Fixed

- (FM-8770) Fix provision_list and tear_down output [#219](https://github.com/puppetlabs/puppet_litmus/pull/219) ([florindragos](https://github.com/florindragos))
- (maint) declare PuppetLitmus module [#216](https://github.com/puppetlabs/puppet_litmus/pull/216) ([DavidS](https://github.com/DavidS))
- Invoke spec_prep before provision_list [#213](https://github.com/puppetlabs/puppet_litmus/pull/213) ([florindragos](https://github.com/florindragos))
- (MODULES-10019) Add exit_status to run_shell [#207](https://github.com/puppetlabs/puppet_litmus/pull/207) ([florindragos](https://github.com/florindragos))

## [0.12.0](https://github.com/puppetlabs/puppet_litmus/tree/0.12.0) - 2019-10-15

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.11.2...0.12.0)

### Added

- (feature) run_bolt_task allows a custom inventory file [#194](https://github.com/puppetlabs/puppet_litmus/pull/194) ([tphoney](https://github.com/tphoney))

## [0.11.2](https://github.com/puppetlabs/puppet_litmus/tree/0.11.2) - 2019-10-11

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.11.1...0.11.2)

### Fixed

- (MODULES-9998) Require pdk/util and remove pdk pin [#203](https://github.com/puppetlabs/puppet_litmus/pull/203) ([florindragos](https://github.com/florindragos))

## [0.11.1](https://github.com/puppetlabs/puppet_litmus/tree/0.11.1) - 2019-10-09

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.11.0...0.11.1)

### Fixed

- (bugfix) pin pdk gem and require tty [#201](https://github.com/puppetlabs/puppet_litmus/pull/201) ([tphoney](https://github.com/tphoney))
- (FM-8346) Create inventory group if missing when adding a node [#198](https://github.com/puppetlabs/puppet_litmus/pull/198) ([florindragos](https://github.com/florindragos))

## [0.11.0](https://github.com/puppetlabs/puppet_litmus/tree/0.11.0) - 2019-10-03

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.10.0...0.11.0)

### Added

- (FM-7077) add install_modules_from_directory [#192](https://github.com/puppetlabs/puppet_litmus/pull/192) ([tphoney](https://github.com/tphoney))

### Fixed

- (FM-8464) Remove bolt version pin [#196](https://github.com/puppetlabs/puppet_litmus/pull/196) ([florindragos](https://github.com/florindragos))
- (bugfix) error on provisionlist with no key [#195](https://github.com/puppetlabs/puppet_litmus/pull/195) ([tphoney](https://github.com/tphoney))

## [0.10.0](https://github.com/puppetlabs/puppet_litmus/tree/0.10.0) - 2019-09-26

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.9.1...0.10.0)

### Changed

- (FM-8513) Better handling of errors and changes [#185](https://github.com/puppetlabs/puppet_litmus/pull/185) ([florindragos](https://github.com/florindragos))
- (FM-8456) set inventory vars when provisioning [#184](https://github.com/puppetlabs/puppet_litmus/pull/184) ([tphoney](https://github.com/tphoney))

### Added

- (FM-8342) Handle mocking of localhost [#179](https://github.com/puppetlabs/puppet_litmus/pull/179) ([michaeltlombardi](https://github.com/michaeltlombardi))

### Fixed

- (FM-8494) fix provision progress in travis and rubocop [#182](https://github.com/puppetlabs/puppet_litmus/pull/182) ([tphoney](https://github.com/tphoney))
- (bugfix) Report both stderr and stdout when an error is detected [#180](https://github.com/puppetlabs/puppet_litmus/pull/180) ([hajee](https://github.com/hajee))
- (FM-8486) Remove tty-spinner when running in CI [#177](https://github.com/puppetlabs/puppet_litmus/pull/177) ([florindragos](https://github.com/florindragos))
- (FM-8488) Correct param loading as env vars in provision_list [#176](https://github.com/puppetlabs/puppet_litmus/pull/176) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (feat) Better puppet error detection and better readable output [#173](https://github.com/puppetlabs/puppet_litmus/pull/173) ([hajee](https://github.com/hajee))

## [0.9.1](https://github.com/puppetlabs/puppet_litmus/tree/0.9.1) - 2019-08-30

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.9.0...0.9.1)

### Added

- (FM-8477) Add paramter to pass hiera config to apply calls [#171](https://github.com/puppetlabs/puppet_litmus/pull/171) ([michaeltlombardi](https://github.com/michaeltlombardi))

## [0.9.0](https://github.com/puppetlabs/puppet_litmus/tree/0.9.0) - 2019-08-23

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.8.2...0.9.0)

## [0.8.2](https://github.com/puppetlabs/puppet_litmus/tree/0.8.2) - 2019-08-23

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.8.1...0.8.2)

### Fixed

- Pin bolt version, latest version breaks docker_exp [#169](https://github.com/puppetlabs/puppet_litmus/pull/169) ([florindragos](https://github.com/florindragos))

## [0.8.1](https://github.com/puppetlabs/puppet_litmus/tree/0.8.1) - 2019-08-19

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.8.0...0.8.1)

### Fixed

- MODULES-9729 update exit code for nil cases [#166](https://github.com/puppetlabs/puppet_litmus/pull/166) ([sheenaajay](https://github.com/sheenaajay))

## [0.8.0](https://github.com/puppetlabs/puppet_litmus/tree/0.8.0) - 2019-08-05

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.7.3...0.8.0)

### Added

- (feat) Add option to run acceptance in serial [#164](https://github.com/puppetlabs/puppet_litmus/pull/164) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (feat) Enable manipulating inventory features by node [#163](https://github.com/puppetlabs/puppet_litmus/pull/163) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (feat) Add support to show apply_manifest output for debugging [#159](https://github.com/puppetlabs/puppet_litmus/pull/159) ([hajee](https://github.com/hajee))

## [0.7.3](https://github.com/puppetlabs/puppet_litmus/tree/0.7.3) - 2019-07-09

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.7.2...0.7.3)

### Fixed

- (bugfix) Use quote around upload path [#156](https://github.com/puppetlabs/puppet_litmus/pull/156) ([hajee](https://github.com/hajee))
- (FM-8303) Ensure run_bolt_task works against localhost [#155](https://github.com/puppetlabs/puppet_litmus/pull/155) ([michaeltlombardi](https://github.com/michaeltlombardi))

## [0.7.2](https://github.com/puppetlabs/puppet_litmus/tree/0.7.2) - 2019-07-03

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.7.1...0.7.2)

### Fixed

- (bugfix) bolt_task populates stdout, if successful [#153](https://github.com/puppetlabs/puppet_litmus/pull/153) ([tphoney](https://github.com/tphoney))

## [0.7.1](https://github.com/puppetlabs/puppet_litmus/tree/0.7.1) - 2019-07-02

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.7.0...0.7.1)

### Fixed

- (bugfix) fix multiple update to inventoryfile [#152](https://github.com/puppetlabs/puppet_litmus/pull/152) ([sheenaajay](https://github.com/sheenaajay))
- (FM-8299) spinner runs after spec_prep in provision [#149](https://github.com/puppetlabs/puppet_litmus/pull/149) ([tphoney](https://github.com/tphoney))
- (FM-8296) Ensure serverspec helpers emit correctly [#147](https://github.com/puppetlabs/puppet_litmus/pull/147) ([michaeltlombardi](https://github.com/michaeltlombardi))

## [0.7.0](https://github.com/puppetlabs/puppet_litmus/tree/0.7.0) - 2019-06-27

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.6.0...0.7.0)

### Added

- FM-8286 run_bolt_task returns bolt result object [#146](https://github.com/puppetlabs/puppet_litmus/pull/146) ([sheenaajay](https://github.com/sheenaajay))
- (FM-8284) Add bolt_run_script command [#145](https://github.com/puppetlabs/puppet_litmus/pull/145) ([eimlav](https://github.com/eimlav))

## [0.6.0](https://github.com/puppetlabs/puppet_litmus/tree/0.6.0) - 2019-06-24

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.5.0...0.6.0)

### Added

- FM-8269 add or remove features in inventory file [#138](https://github.com/puppetlabs/puppet_litmus/pull/138) ([sheenaajay](https://github.com/sheenaajay))
- (FM-8178) Make params passable using provision.yaml [#137](https://github.com/puppetlabs/puppet_litmus/pull/137) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (FM-8268) adding file/directory upload method [#136](https://github.com/puppetlabs/puppet_litmus/pull/136) ([tphoney](https://github.com/tphoney))

### Fixed

- (bugfix) check for litmus env vars in params [#141](https://github.com/puppetlabs/puppet_litmus/pull/141) ([tphoney](https://github.com/tphoney))
- (minor fix for add_feature_to_group function) [#140](https://github.com/puppetlabs/puppet_litmus/pull/140) ([sheenaajay](https://github.com/sheenaajay))
- (FM-8273) Enable parallel acceptance from Windows [#139](https://github.com/puppetlabs/puppet_litmus/pull/139) ([michaeltlombardi](https://github.com/michaeltlombardi))

## [0.5.0](https://github.com/puppetlabs/puppet_litmus/tree/0.5.0) - 2019-06-13

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.4.0...0.5.0)

### Added

- (FM-8185) Use spinner when provisioning  [#130](https://github.com/puppetlabs/puppet_litmus/pull/130) ([florindragos](https://github.com/florindragos))
- (feat) add provision_and_install task [#128](https://github.com/puppetlabs/puppet_litmus/pull/128) ([tphoney](https://github.com/tphoney))
- (FM-7963) Add yardoc comments to inventory_manipulation and rake_task… [#127](https://github.com/puppetlabs/puppet_litmus/pull/127) ([ThoughtCrhyme](https://github.com/ThoughtCrhyme))
- Addition of pe_install rake task [#124](https://github.com/puppetlabs/puppet_litmus/pull/124) ([HelenCampbell](https://github.com/HelenCampbell))

### Fixed

- (FM-8249) add localhost check to run_shell [#134](https://github.com/puppetlabs/puppet_litmus/pull/134) ([ThoughtCrhyme](https://github.com/ThoughtCrhyme))
- Update the install_pe experimental rake task [#131](https://github.com/puppetlabs/puppet_litmus/pull/131) ([gregohardy](https://github.com/gregohardy))

## [0.4.0](https://github.com/puppetlabs/puppet_litmus/tree/0.4.0) - 2019-05-30

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.3.1...0.4.0)

### Added

- (FM-8072) add noop flag detection to apply_manifest [#119](https://github.com/puppetlabs/puppet_litmus/pull/119) ([ThoughtCrhyme](https://github.com/ThoughtCrhyme))

### Fixed

- (bugfix) raise on task failure [#120](https://github.com/puppetlabs/puppet_litmus/pull/120) ([tphoney](https://github.com/tphoney))

## [0.3.1](https://github.com/puppetlabs/puppet_litmus/tree/0.3.1) - 2019-05-29

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.3.0...0.3.1)

### Fixed

- (bugfix) fix result object for bolt task [#117](https://github.com/puppetlabs/puppet_litmus/pull/117) ([tphoney](https://github.com/tphoney))

## [0.3.0](https://github.com/puppetlabs/puppet_litmus/tree/0.3.0) - 2019-05-29

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.2.0...0.3.0)

### Added

- (feat) better error message for agent_install [#114](https://github.com/puppetlabs/puppet_litmus/pull/114) ([tphoney](https://github.com/tphoney))
- (MODULES-9170) allow for the new docker provisioner [#113](https://github.com/puppetlabs/puppet_litmus/pull/113) ([tphoney](https://github.com/tphoney))

### Fixed

- (FM-8105) when in CI correctly display test summary [#115](https://github.com/puppetlabs/puppet_litmus/pull/115) ([tphoney](https://github.com/tphoney))
- (FM-8094) remove workaround for bolt on windows [#112](https://github.com/puppetlabs/puppet_litmus/pull/112) ([tphoney](https://github.com/tphoney))
- (bugfix) handle block in bolt_task [#111](https://github.com/puppetlabs/puppet_litmus/pull/111) ([tphoney](https://github.com/tphoney))

## [0.2.0](https://github.com/puppetlabs/puppet_litmus/tree/0.2.0) - 2019-05-15

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.1.1...0.2.0)

### Added

- (FM-8073) Support blocks in apply_manifest [#108](https://github.com/puppetlabs/puppet_litmus/pull/108) ([tphoney](https://github.com/tphoney))
- (FM-7978) use a spinner for parallel acceptance [#101](https://github.com/puppetlabs/puppet_litmus/pull/101) ([tphoney](https://github.com/tphoney))
- (FM-7963) Yard doc for serverspec [#99](https://github.com/puppetlabs/puppet_litmus/pull/99) ([tphoney](https://github.com/tphoney))
- (FM-7718) Support vagrant provisioning [#92](https://github.com/puppetlabs/puppet_litmus/pull/92) ([florindragos](https://github.com/florindragos))

### Fixed

- (FM-8021) remove output to html, for now [#107](https://github.com/puppetlabs/puppet_litmus/pull/107) ([tphoney](https://github.com/tphoney))
- Added require for tempfile [#102](https://github.com/puppetlabs/puppet_litmus/pull/102) ([dylanratcliffe](https://github.com/dylanratcliffe))
- (bugfix) typo in error msg of apply_manifest [#100](https://github.com/puppetlabs/puppet_litmus/pull/100) ([tphoney](https://github.com/tphoney))

## [0.1.1](https://github.com/puppetlabs/puppet_litmus/tree/0.1.1) - 2019-04-29

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.1.0...0.1.1)

### Fixed

- (bugfix) fix ruby loading of litmus [#95](https://github.com/puppetlabs/puppet_litmus/pull/95) ([tphoney](https://github.com/tphoney))

## [0.1.0](https://github.com/puppetlabs/puppet_litmus/tree/0.1.0) - 2019-04-29

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.0.1...0.1.0)

### Changed

- (FM-7470) change method names, use upload_file [#91](https://github.com/puppetlabs/puppet_litmus/pull/91) ([tphoney](https://github.com/tphoney))

### Added

- (FM-7891) separate serverspec helpers and add unit [#90](https://github.com/puppetlabs/puppet_litmus/pull/90) ([tphoney](https://github.com/tphoney))
- (feat) changelog-generator working with litmus [#87](https://github.com/puppetlabs/puppet_litmus/pull/87) ([tphoney](https://github.com/tphoney))

### Fixed

- (FM-7981) raise in provision_list if one fails [#93](https://github.com/puppetlabs/puppet_litmus/pull/93) ([tphoney](https://github.com/tphoney))

## [0.0.1](https://github.com/puppetlabs/puppet_litmus/tree/0.0.1) - 2019-04-15

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/d95f233cfb3ac737c841d10eae3796d35af62d3e...0.0.1)
