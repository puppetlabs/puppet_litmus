# Litmus

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

## matrix_from_metadata_v2

matrix_from_metadata_v2 tool generates a github action matrix from the supported operating systems listed in the module's metadata.json.

How to use it:
in the project module root directory run `bundle exec matrix_from_metadata_v2`

### --exclude-platforms parameter

matrix_from_metadata_v2 accepts the `--exclude-platforms <JSON array>` argument in order to exclude some platforms from the matrix.

For example:

`$: bundle exec matrix_from_metadata_v2 --exclude-platforms '["debian-11","centos-8"]'`

> Note: The option value should be JSON string otherwise it will throw an error.
> The values provided in the json array are case-insensitive `["debian-11","centos-8"]'` or `["Debian-11","CentOS-8"]'` are treated as being the same.

### --custom-matrix parameter

matrix_from_metadata_v2 accepts the `--custom-matrix /path/to/matrix.json` argument in order to execute your test suite against a custom matrix. This is useful for use cases that do not fit the default matrix generated.

In order to use this new functionality, run:

`$: bundle exec matrix_from_metadata_v2 --custom-matrix matrix.json`

> Note: The file should contain a valid Array of JSON Objects (i.e. `[{"label":"AlmaLinux-8","provider":"provision_service","image":"almalinux-cloud/almalinux-8"}, {..}]`), otherwise it will throw an error.

## Documentation

For documentation, see our [Litmus Docs Site](https://puppetlabs.github.io/content-and-tooling-team/docs/litmus/).

## Other Resources

- [Is it Worth the Time?](https://xkcd.com/1205/)
