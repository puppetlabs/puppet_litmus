# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [0.17.0](https://github.com/puppetlabs/puppet_litmus/tree/0.17.0) (2020-03-24)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.16.0...0.17.0)

### Added

- \(IAC-373\) link spans to an existing trace using HTTP\_X\_HONEYCOMB\_TRACE [\#265](https://github.com/puppetlabs/puppet_litmus/pull/265) ([DavidS](https://github.com/DavidS))
- \(IAC-537\) capture more info for honeycomb [\#264](https://github.com/puppetlabs/puppet_litmus/pull/264) ([DavidS](https://github.com/DavidS))
- Open Litmus to use custom provisioners [\#262](https://github.com/puppetlabs/puppet_litmus/pull/262) ([jmangt](https://github.com/jmangt))

## [0.16.0](https://github.com/puppetlabs/puppet_litmus/tree/0.16.0) (2020-03-09)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.15.0...0.16.0)

### Added

- \(MAINT\) Add interpolate\_powershell helper method [\#244](https://github.com/puppetlabs/puppet_litmus/pull/244) ([michaeltlombardi](https://github.com/michaeltlombardi))
- \(IAC-536\) Unify honeycomb field names; fallback for branch builds [\#243](https://github.com/puppetlabs/puppet_litmus/pull/243) ([DavidS](https://github.com/DavidS))
- \(IAC-490\) Add CI checks and metadata information of github action [\#241](https://github.com/puppetlabs/puppet_litmus/pull/241) ([sheenaajay](https://github.com/sheenaajay))

### Fixed

- Make InventoryManipulation available to all rake tasks [\#251](https://github.com/puppetlabs/puppet_litmus/pull/251) ([DavidS](https://github.com/DavidS))
- \(GH-246\) Fix install\_modules\_from\_directory logic [\#248](https://github.com/puppetlabs/puppet_litmus/pull/248) ([michaeltlombardi](https://github.com/michaeltlombardi))
- \(GH-234\) Remove PDK dependency [\#235](https://github.com/puppetlabs/puppet_litmus/pull/235) ([glennsarti](https://github.com/glennsarti))

## [0.15.0](https://github.com/puppetlabs/puppet_litmus/tree/0.15.0) (2020-02-03)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.14.0...0.15.0)

### Changed

- \(feat\) move to v2 of bolt inventory file [\#233](https://github.com/puppetlabs/puppet_litmus/pull/233) ([tphoney](https://github.com/tphoney))

### Added

- \(MODULES-10478\) honeycomb integration to litmus [\#238](https://github.com/puppetlabs/puppet_litmus/pull/238) ([sheenaajay](https://github.com/sheenaajay))
- \(feat\) - new rake task to add a given feature to a group of nodes [\#236](https://github.com/puppetlabs/puppet_litmus/pull/236) ([david22swan](https://github.com/david22swan))
- \(MAINT\) Ensure acceptance:localhost task also runs spec\_prep [\#206](https://github.com/puppetlabs/puppet_litmus/pull/206) ([RandomNoun7](https://github.com/RandomNoun7))

## [0.14.0](https://github.com/puppetlabs/puppet_litmus/tree/0.14.0) (2020-01-23)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.13.1...0.14.0)

### Added

- \(feat\) check connectivity status, after testing completes [\#231](https://github.com/puppetlabs/puppet_litmus/pull/231) ([tphoney](https://github.com/tphoney))
- \(feat\) new rake task to check nodes are available [\#230](https://github.com/puppetlabs/puppet_litmus/pull/230) ([tphoney](https://github.com/tphoney))

### Fixed

- Improve error reporting [\#228](https://github.com/puppetlabs/puppet_litmus/pull/228) ([DavidS](https://github.com/DavidS))
- \(MODULES-10018\) Extend RSpec config with PuppetLitmus [\#226](https://github.com/puppetlabs/puppet_litmus/pull/226) ([michaeltlombardi](https://github.com/michaeltlombardi))
- \(MODULES-10115\) Fix Windows endpoint declaration when using TARGET\_HOST [\#224](https://github.com/puppetlabs/puppet_litmus/pull/224) ([michaeltlombardi](https://github.com/michaeltlombardi))

## [0.13.1](https://github.com/puppetlabs/puppet_litmus/tree/0.13.1) (2019-12-11)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.13.0...0.13.1)

### Fixed

- \(FM-8772\) Fix install\_agent error output message [\#221](https://github.com/puppetlabs/puppet_litmus/pull/221) ([florindragos](https://github.com/florindragos))

## [0.13.0](https://github.com/puppetlabs/puppet_litmus/tree/0.13.0) (2019-12-04)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.12.0...0.13.0)

### Added

- \(FM-8355\) Add spec\_helper\_acceptance [\#210](https://github.com/puppetlabs/puppet_litmus/pull/210) ([florindragos](https://github.com/florindragos))
- \(FM-8611\) Reinstall module [\#209](https://github.com/puppetlabs/puppet_litmus/pull/209) ([florindragos](https://github.com/florindragos))

### Fixed

- \(FM-8770\) Fix provision\_list and tear\_down output [\#219](https://github.com/puppetlabs/puppet_litmus/pull/219) ([florindragos](https://github.com/florindragos))
- \(maint\) declare PuppetLitmus module [\#216](https://github.com/puppetlabs/puppet_litmus/pull/216) ([DavidS](https://github.com/DavidS))
- Invoke spec\_prep before provision\_list [\#213](https://github.com/puppetlabs/puppet_litmus/pull/213) ([florindragos](https://github.com/florindragos))
- \(MODULES-10019\) Add exit\_status to run\_shell [\#207](https://github.com/puppetlabs/puppet_litmus/pull/207) ([florindragos](https://github.com/florindragos))

## [0.12.0](https://github.com/puppetlabs/puppet_litmus/tree/0.12.0) (2019-10-15)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.11.2...0.12.0)

### Added

- \(feature\) run\_bolt\_task allows a custom inventory file [\#194](https://github.com/puppetlabs/puppet_litmus/pull/194) ([tphoney](https://github.com/tphoney))

## [0.11.2](https://github.com/puppetlabs/puppet_litmus/tree/0.11.2) (2019-10-11)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.11.1...0.11.2)

### Fixed

- \(MODULES-9998\) Require pdk/util and remove pdk pin [\#203](https://github.com/puppetlabs/puppet_litmus/pull/203) ([florindragos](https://github.com/florindragos))

## [0.11.1](https://github.com/puppetlabs/puppet_litmus/tree/0.11.1) (2019-10-09)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.11.0...0.11.1)

### Fixed

- \(bugfix\) pin pdk gem and require tty [\#201](https://github.com/puppetlabs/puppet_litmus/pull/201) ([tphoney](https://github.com/tphoney))
- \(FM-8346\) Create inventory group if missing when adding a node [\#198](https://github.com/puppetlabs/puppet_litmus/pull/198) ([florindragos](https://github.com/florindragos))

## [0.11.0](https://github.com/puppetlabs/puppet_litmus/tree/0.11.0) (2019-10-03)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.10.0...0.11.0)

### Added

- \(FM-7077\) add install\_modules\_from\_directory [\#192](https://github.com/puppetlabs/puppet_litmus/pull/192) ([tphoney](https://github.com/tphoney))

### Fixed

- \(FM-8464\) Remove bolt version pin [\#196](https://github.com/puppetlabs/puppet_litmus/pull/196) ([florindragos](https://github.com/florindragos))
- \(bugfix\) error on provisionlist with no key [\#195](https://github.com/puppetlabs/puppet_litmus/pull/195) ([tphoney](https://github.com/tphoney))

## [0.10.0](https://github.com/puppetlabs/puppet_litmus/tree/0.10.0) (2019-09-26)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.9.1...0.10.0)

### Changed

- \(FM-8513\) Better handling of errors and changes [\#185](https://github.com/puppetlabs/puppet_litmus/pull/185) ([florindragos](https://github.com/florindragos))
- \(FM-8456\) set inventory vars when provisioning [\#184](https://github.com/puppetlabs/puppet_litmus/pull/184) ([tphoney](https://github.com/tphoney))

### Added

- \(FM-8342\) Handle mocking of localhost [\#179](https://github.com/puppetlabs/puppet_litmus/pull/179) ([michaeltlombardi](https://github.com/michaeltlombardi))

### Fixed

- \(FM-8494\) fix provision progress in travis and rubocop [\#182](https://github.com/puppetlabs/puppet_litmus/pull/182) ([tphoney](https://github.com/tphoney))
- \(bugfix\) Report both stderr and stdout when an error is detected [\#180](https://github.com/puppetlabs/puppet_litmus/pull/180) ([hajee](https://github.com/hajee))
- \(feat\) Better puppet error detection and better readable output [\#173](https://github.com/puppetlabs/puppet_litmus/pull/173) ([hajee](https://github.com/hajee))

## [0.9.1](https://github.com/puppetlabs/puppet_litmus/tree/0.9.1) (2019-09-04)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.9.0...0.9.1)

### Fixed

- \(FM-8486\) Remove tty-spinner when running in CI [\#177](https://github.com/puppetlabs/puppet_litmus/pull/177) ([florindragos](https://github.com/florindragos))
- \(FM-8488\) Correct param loading as env vars in provision\_list [\#176](https://github.com/puppetlabs/puppet_litmus/pull/176) ([michaeltlombardi](https://github.com/michaeltlombardi))

## [0.9.0](https://github.com/puppetlabs/puppet_litmus/tree/0.9.0) (2019-08-29)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.8.2...0.9.0)

### Added

- \(FM-8477\) Add paramter to pass hiera config to apply calls [\#171](https://github.com/puppetlabs/puppet_litmus/pull/171) ([michaeltlombardi](https://github.com/michaeltlombardi))

## [0.8.2](https://github.com/puppetlabs/puppet_litmus/tree/0.8.2) (2019-08-23)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.8.1...0.8.2)

### Fixed

- Pin bolt version, latest version breaks docker\_exp [\#169](https://github.com/puppetlabs/puppet_litmus/pull/169) ([florindragos](https://github.com/florindragos))

## [0.8.1](https://github.com/puppetlabs/puppet_litmus/tree/0.8.1) (2019-08-19)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.8.0...0.8.1)

### Fixed

- MODULES-9729 update exit code for nil cases [\#166](https://github.com/puppetlabs/puppet_litmus/pull/166) ([sheenaajay](https://github.com/sheenaajay))

## [0.8.0](https://github.com/puppetlabs/puppet_litmus/tree/0.8.0) (2019-08-05)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.7.3...0.8.0)

### Added

- \(feat\) Add option to run acceptance in serial [\#164](https://github.com/puppetlabs/puppet_litmus/pull/164) ([michaeltlombardi](https://github.com/michaeltlombardi))
- \(feat\) Enable manipulating inventory features by node [\#163](https://github.com/puppetlabs/puppet_litmus/pull/163) ([michaeltlombardi](https://github.com/michaeltlombardi))
- \(feat\) Add support to show apply\_manifest output for debugging [\#159](https://github.com/puppetlabs/puppet_litmus/pull/159) ([hajee](https://github.com/hajee))

## [0.7.3](https://github.com/puppetlabs/puppet_litmus/tree/0.7.3) (2019-07-09)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.7.2...0.7.3)

### Fixed

- \(bugfix\) Use quote around upload path [\#156](https://github.com/puppetlabs/puppet_litmus/pull/156) ([hajee](https://github.com/hajee))
- \(FM-8303\) Ensure run\_bolt\_task works against localhost [\#155](https://github.com/puppetlabs/puppet_litmus/pull/155) ([michaeltlombardi](https://github.com/michaeltlombardi))

## [0.7.2](https://github.com/puppetlabs/puppet_litmus/tree/0.7.2) (2019-07-03)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.7.1...0.7.2)

### Fixed

- \(bugfix\) bolt\_task populates stdout, if successful [\#153](https://github.com/puppetlabs/puppet_litmus/pull/153) ([tphoney](https://github.com/tphoney))

## [0.7.1](https://github.com/puppetlabs/puppet_litmus/tree/0.7.1) (2019-07-02)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.7.0...0.7.1)

### Fixed

- \(bugfix\) fix multiple update to inventoryfile [\#152](https://github.com/puppetlabs/puppet_litmus/pull/152) ([sheenaajay](https://github.com/sheenaajay))
- \(FM-8299\) spinner runs after spec\_prep in provision [\#149](https://github.com/puppetlabs/puppet_litmus/pull/149) ([tphoney](https://github.com/tphoney))
- \(FM-8296\) Ensure serverspec helpers emit correctly [\#147](https://github.com/puppetlabs/puppet_litmus/pull/147) ([michaeltlombardi](https://github.com/michaeltlombardi))

## [0.7.0](https://github.com/puppetlabs/puppet_litmus/tree/0.7.0) (2019-06-27)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.6.0...0.7.0)

### Added

- FM-8286 run\_bolt\_task returns bolt result object [\#146](https://github.com/puppetlabs/puppet_litmus/pull/146) ([sheenaajay](https://github.com/sheenaajay))
- \(FM-8284\) Add bolt\_run\_script command [\#145](https://github.com/puppetlabs/puppet_litmus/pull/145) ([eimlav](https://github.com/eimlav))

## [0.6.0](https://github.com/puppetlabs/puppet_litmus/tree/0.6.0) (2019-06-24)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.5.0...0.6.0)

### Added

- FM-8269 add or remove features in inventory file [\#138](https://github.com/puppetlabs/puppet_litmus/pull/138) ([sheenaajay](https://github.com/sheenaajay))
- \(FM-8178\) Make params passable using provision.yaml [\#137](https://github.com/puppetlabs/puppet_litmus/pull/137) ([michaeltlombardi](https://github.com/michaeltlombardi))
- \(FM-8268\) adding file/directory upload method [\#136](https://github.com/puppetlabs/puppet_litmus/pull/136) ([tphoney](https://github.com/tphoney))

### Fixed

- \(bugfix\) check for litmus env vars in params [\#141](https://github.com/puppetlabs/puppet_litmus/pull/141) ([tphoney](https://github.com/tphoney))
- \(minor fix for add\_feature\_to\_group function\) [\#140](https://github.com/puppetlabs/puppet_litmus/pull/140) ([sheenaajay](https://github.com/sheenaajay))
- \(FM-8273\) Enable parallel acceptance from Windows [\#139](https://github.com/puppetlabs/puppet_litmus/pull/139) ([michaeltlombardi](https://github.com/michaeltlombardi))

## [0.5.0](https://github.com/puppetlabs/puppet_litmus/tree/0.5.0) (2019-06-13)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.4.0...0.5.0)

### Added

- \(FM-8185\) Use spinner when provisioning  [\#130](https://github.com/puppetlabs/puppet_litmus/pull/130) ([florindragos](https://github.com/florindragos))
- \(feat\) add provision\_and\_install task [\#128](https://github.com/puppetlabs/puppet_litmus/pull/128) ([tphoney](https://github.com/tphoney))
- \(FM-7963\) Add yardoc comments to inventory\_manipulation and rake\_task… [\#127](https://github.com/puppetlabs/puppet_litmus/pull/127) ([ThoughtCrhyme](https://github.com/ThoughtCrhyme))
- Addition of pe\_install rake task [\#124](https://github.com/puppetlabs/puppet_litmus/pull/124) ([HelenCampbell](https://github.com/HelenCampbell))

### Fixed

- \(FM-8249\) add localhost check to run\_shell [\#134](https://github.com/puppetlabs/puppet_litmus/pull/134) ([ThoughtCrhyme](https://github.com/ThoughtCrhyme))
- Update the install\_pe experimental rake task [\#131](https://github.com/puppetlabs/puppet_litmus/pull/131) ([gregohardy](https://github.com/gregohardy))

## [0.4.0](https://github.com/puppetlabs/puppet_litmus/tree/0.4.0) (2019-05-30)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.3.1...0.4.0)

### Added

- \(FM-8072\) add noop flag detection to apply\_manifest [\#119](https://github.com/puppetlabs/puppet_litmus/pull/119) ([ThoughtCrhyme](https://github.com/ThoughtCrhyme))

### Fixed

- \(bugfix\) raise on task failure [\#120](https://github.com/puppetlabs/puppet_litmus/pull/120) ([tphoney](https://github.com/tphoney))

## [0.3.1](https://github.com/puppetlabs/puppet_litmus/tree/0.3.1) (2019-05-29)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.3.0...0.3.1)

### Fixed

- \(bugfix\) fix result object for bolt task [\#117](https://github.com/puppetlabs/puppet_litmus/pull/117) ([tphoney](https://github.com/tphoney))

## [0.3.0](https://github.com/puppetlabs/puppet_litmus/tree/0.3.0) (2019-05-29)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.2.0...0.3.0)

### Added

- \(feat\) better error message for agent\_install [\#114](https://github.com/puppetlabs/puppet_litmus/pull/114) ([tphoney](https://github.com/tphoney))
- \(MODULES-9170\) allow for the new docker provisioner [\#113](https://github.com/puppetlabs/puppet_litmus/pull/113) ([tphoney](https://github.com/tphoney))

### Fixed

- \(FM-8105\) when in CI correctly display test summary [\#115](https://github.com/puppetlabs/puppet_litmus/pull/115) ([tphoney](https://github.com/tphoney))
- \(FM-8094\) remove workaround for bolt on windows [\#112](https://github.com/puppetlabs/puppet_litmus/pull/112) ([tphoney](https://github.com/tphoney))
- \(bugfix\) handle block in bolt\_task [\#111](https://github.com/puppetlabs/puppet_litmus/pull/111) ([tphoney](https://github.com/tphoney))

## [0.2.0](https://github.com/puppetlabs/puppet_litmus/tree/0.2.0) (2019-05-15)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.1.1...0.2.0)

### Added

- \(FM-8073\) Support blocks in apply\_manifest [\#108](https://github.com/puppetlabs/puppet_litmus/pull/108) ([tphoney](https://github.com/tphoney))
- \(FM-7978\) use a spinner for parallel acceptance [\#101](https://github.com/puppetlabs/puppet_litmus/pull/101) ([tphoney](https://github.com/tphoney))
- \(FM-7963\) Yard doc for serverspec [\#99](https://github.com/puppetlabs/puppet_litmus/pull/99) ([tphoney](https://github.com/tphoney))
- \(FM-7718\) Support vagrant provisioning [\#92](https://github.com/puppetlabs/puppet_litmus/pull/92) ([florindragos](https://github.com/florindragos))

### Fixed

- \(FM-8021\) remove output to html, for now [\#107](https://github.com/puppetlabs/puppet_litmus/pull/107) ([tphoney](https://github.com/tphoney))
- Added require for tempfile [\#102](https://github.com/puppetlabs/puppet_litmus/pull/102) ([dylanratcliffe](https://github.com/dylanratcliffe))
- \(bugfix\) typo in error msg of apply\_manifest [\#100](https://github.com/puppetlabs/puppet_litmus/pull/100) ([tphoney](https://github.com/tphoney))

## [0.1.1](https://github.com/puppetlabs/puppet_litmus/tree/0.1.1) (2019-04-29)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.1.0...0.1.1)

### Fixed

- \(bugfix\) fix ruby loading of litmus [\#95](https://github.com/puppetlabs/puppet_litmus/pull/95) ([tphoney](https://github.com/tphoney))

## [0.1.0](https://github.com/puppetlabs/puppet_litmus/tree/0.1.0) (2019-04-29)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.0.1...0.1.0)

### Changed

- \(FM-7470\) change method names, use upload\_file [\#91](https://github.com/puppetlabs/puppet_litmus/pull/91) ([tphoney](https://github.com/tphoney))

### Added

- \(FM-7891\) separate serverspec helpers and add unit [\#90](https://github.com/puppetlabs/puppet_litmus/pull/90) ([tphoney](https://github.com/tphoney))
- \(feat\) changelog-generator working with litmus [\#87](https://github.com/puppetlabs/puppet_litmus/pull/87) ([tphoney](https://github.com/tphoney))
- \(feat\) set pdk and bolt in gemspec [\#84](https://github.com/puppetlabs/puppet_litmus/pull/84) ([tphoney](https://github.com/tphoney))

### Fixed

- \(FM-7981\) raise in provision\_list if one fails [\#93](https://github.com/puppetlabs/puppet_litmus/pull/93) ([tphoney](https://github.com/tphoney))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
