# Litmus

[![Code Owners](https://img.shields.io/badge/owners-DevX--team-blue)](https://github.com/puppetlabs/puppet_litmus/blob/main/CODEOWNERS)
![ci](https://github.com/puppetlabs/puppet_litmus/actions/workflows/ci.yml/badge.svg)
[![Gem Version](https://badge.fury.io/rb/puppet_litmus.svg)](https://badge.fury.io/rb/puppet_litmus)

<div name="logo">
  <img src="resources/litmus-dark-RGB.png"
  style="display: block; margin-left: auto; margin-right: auto;"
  width="50%"
  alt="litmus logo">
</div>

## Overview

Litmus is a command line tool that allows you to run acceptance tests against Puppet modules.

Litmus allows you to:

- Provision targets to test against
- Install a Puppet agent
- Install a module
- Run tests
- Tear down the infrastructure

Litmus also facilitates parallel test runs and running tests in isolation. Each step is standalone, allowing other operations between test runs, such as debugging or configuration updates on the test targets.

Install Litmus as a gem by running `gem install puppet_litmus`.

- Note if you choose to override the `litmus_inventory.yaml` location, please ensure that the directory structure you define exists.

## Agent installs

### Install a specific puppet agent version

To install a specific version of the puppet agent, you can export the `PUPPET_VERSION` env var, like below:
```
export PUPPET_VERSION=8.8.1
```

When set, the `litmus:install_agent` rake task will install the specified version. The default is `latest`.

## Installing puppetcore agents

To install a puppetcore puppet agent through the `litmus:install_agent` rake task, you need to export your Forge API key as an env var, like below:
```
export PUPPET_FORGE_TOKEN='<your_forge_api_key>'
```

## matrix_from_metadata_v3

matrix_from_metadata_v3 tool generates a github action matrix from the supported operating systems listed in the module's metadata.json.

How to use it:
in the project module root directory run `bundle exec matrix_from_metadata_v3`

### Optional arguments

| argument            | value | default           | description |
|---------------------|-------|-------------------|-------------|
| --matrix            | FILE  | built-in          | File containing possible collections and provisioners |
| --metadata          | FILE  | metadata.json     | File containing module metadata json |
| --debug             |       |                   | Enable debug messages |
| --quiet             |       |                   | Disable notice messages |
| --output            | TYPE  | auto              | Type of output to generate; auto, github or stdout |
| --runner            | NAME  | ubuntu-latest     | Default Github action runner |
| --puppet-include    | MAJOR |                   | Select puppet major version |
| --puppet-exclude    | MAJOR |                   | Filter puppet major version |
| --platform-include  | REGEX |                   | Select platform |
| --platform-exclude  | REGEX |                   | Filter platform |
| --arch-include      | REGEX |                   | Select architecture |
| --arch-exclude      | REGEX |                   | Filter architecture |
| --provision-prefer  | NAME  | docker            | Prefer provisioner |
| --provision-include | NAME  | all               | Select provisioner |
| --provision-exclude | NAME  | provision_service | Filter provisioner |
| --nightly           |       |                   | Install from the nightly puppetcore images |

> Refer to the [built-in matrix.json](https://github.com/puppetlabs/puppet_litmus/blob/main/exe/matrix.json) for a list of supported collection, provisioners, and platforms.

### Examples

* Only specific platforms
  ```sh
  matrix_from_metadata_v3 --platform-include redhat --platform-include 'ubuntu-(20|22).04'
  ```
* Exclude platforms
  ```sh
  matrix_from_metadata_v3 --platform-exclude redhat-7 --platform-exclude ubuntu-18.04
  ```
* Exclude architecture
  ```sh
  matrix_from_metadata_v3 --arch-exclude x86_64
  ```
* Run against the nightly puppetcore images
  ```sh
  matrix_from_metadata_v3 --nightly
  ```

## Documentation

For documentation, see our [Litmus Docs Site](https://puppetlabs.github.io/content-and-tooling-team/docs/litmus/).

## License

This codebase is licensed under Apache 2.0. However, the open source dependencies included in this codebase might be subject to other software licenses such as AGPL, GPL2.0, and MIT.

## Other Resources

- [Is it Worth the Time?](https://xkcd.com/1205/)
