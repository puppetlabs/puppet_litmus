# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [0.5.0](https://github.com/puppetlabs/puppet_litmus/tree/0.5.0) (2019-06-12)

[Full Changelog](https://github.com/puppetlabs/puppet_litmus/compare/0.4.0...0.5.0)

### Added

- \(FM-8185\) Use spinner when provisioning  [\#130](https://github.com/puppetlabs/puppet_litmus/pull/130) ([florindragos](https://github.com/florindragos))
- \(feat\) add provision\_and\_install task [\#128](https://github.com/puppetlabs/puppet_litmus/pull/128) ([tphoney](https://github.com/tphoney))
- \(FM-7963\) Add yardoc comments to inventory\_manipulation and rake\_task… [\#127](https://github.com/puppetlabs/puppet_litmus/pull/127) ([ThoughtCrhyme](https://github.com/ThoughtCrhyme))
- Addition of pe\_install rake task [\#124](https://github.com/puppetlabs/puppet_litmus/pull/124) ([HelenCampbell](https://github.com/HelenCampbell))

### Fixed

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
