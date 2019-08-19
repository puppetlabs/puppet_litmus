# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

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



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
