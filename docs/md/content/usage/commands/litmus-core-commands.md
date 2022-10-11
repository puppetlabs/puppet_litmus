---
layout: page
title: Core commands
description: Learn Litmus core commands.
---

Using the Litmus commands, you can provision test platforms such as containers/images, install a Puppet agent, install a module and run tests.

Litmus has five commands:

1. [Provision: 'rake litmus:provision'](#provision)
2. [Install the agent: 'rake litmus:install_agent](#agent)
3. [Install the module: 'rake litmus:install_module'](#module)
4. [Run the tests: 'rake litmus:acceptance:parallel'](#test)
5. [Remove the provisioned machines: 'rake litmus:tear_down'](#teardown)

These commands allow you to create a test environment and run tests against your systems. Note that not all of these steps are needed for every deployment.

Three common test setups are:
  * Run against localhost
  * Run against an existing machine that has Puppet installed
  * Provision a fresh system and install Puppet

Once you have your environment, Litmus is designed to speed up the following workflow:

```
edit code -> install module -> run test
```

At any point you can re-run tests, or provision new systems and add them to your test environment.

<a name="provision"/>

## Provisioning

Using the Litmus [provision](https://github.com/puppetlabs/provision) command, you can spin up Docker containers, vagrant boxes or VMs in private clouds, such as vmpooler.

For example:

```
pdk bundle exec rake 'litmus:provision[vmpooler, redhat-6-x86_64]'
pdk bundle exec rake 'litmus:provision[docker, litmusimage/ubuntu:18.04]'
pdk bundle exec rake 'litmus:provision[vagrant, gusztavvargadr/windows-server]'
```

> Note: Provisioning is extensible — if your chosen provisioner isn't available, you can add your own provisioner task to your test set up through a separate module in `.fixtures.yml`.

The provision command creates a Bolt `spec/fixtures/litmus_inventory.yml` file for Litmus to use. You can manually add machines to this file.

For example:

```yaml
---
version: 2
groups:
- name: docker_nodes
  targets: []
- name: ssh_nodes
  targets:
  - uri: localhost:2222
    config:
      transport: ssh
      ssh:
        user: root
        password: root
        port: 2222
        host-key-check: false
    facts:
      provisioner: docker
      container_name: centos_7-2222
      platform: centos:7
- name: winrm_nodes
  targets: []
```

For more examples of inventory files, see the [Bolt documentation](https://puppet.com/docs/bolt/latest/inventory_file_v2.html).

Note that you can test some modules against localhost — the machine you are running your test from. Note that this is only recommended if you are familiar with the code base, as tests may have unexpected side effects on your local machine. To run a test against localhost, see [Run the tests: 'rake litmus:parallel'](#test)

### Testing services

For testing services that require a service manager (like systemd), the default Docker images might not be enough. In this case, there is a collection of Docker images, with a service manager enabled, based on https://github.com/puppetlabs/litmusimage. For available images, see the [docker hub](https://hub.docker.com/u/litmusimage).

Alternatively, you can use a dedicated VM that uses another provisioner, for example vmpooler or vagrant.

### Provisioning via YAML

In addition to directly provisioning one or more machines using `litmus:provision`, you can also define one or more sets of nodes in a `provision.yaml` file and use that to provision targets.

An example of a `provision.yaml` defining a single node:

```yaml
---
list_name:
  provisioner: vagrant
  images: ['centos/7', 'generic/ubuntu1804', 'gusztavvargadr/windows-server']
  params:
    param_a: someone
    param_b: something
```

Take note of the following:

- The `list_name` is arbitrary and can be any string you want.
- The `provisioner` specifies which provision task to use.
- The `images` must specify an array of one or more images to provision.
- Any keys inside of `params` will be turned into process-scope environment variables as the key, upcased. In the example above, `param_a` would become an environment variable called `PARAM_A` with a value of `someone`.

An example of a `provision.yaml` defining multiple nodes:

```yaml
---
---
default:
  provisioner: docker
  images: ['litmusimage/centos:7']
vagrant:
  provisioner: vagrant
  images: ['centos/7', 'generic/ubuntu1804', 'gusztavvargadr/windows-server']
travis_deb:
  provisioner: docker
  images: ['litmusimage/debian:8', 'litmusimage/debian:9', 'litmusimage/debian:10']
travis_ub:
  provisioner: docker
  images: ['litmusimage/ubuntu:14.04', 'litmusimage/ubuntu:16.04', 'litmusimage/ubuntu:18.04']
travis_el6:
  provisioner: docker
  images: ['litmusimage/centos:6', 'litmusimage/oraclelinux:6', 'litmusimage/scientificlinux:6']
travis_el7:
  provisioner: docker
  images: ['litmusimage/centos:7', 'litmusimage/oraclelinux:7', 'litmusimage/scientificlinux:7']
release_checks:
  provisioner: vmpooler
  images: ['redhat-5-x86_64', 'redhat-6-x86_64', 'redhat-7-x86_64', 'redhat-8-x86_64', 'centos-5-x86_64', 'centos-6-x86_64', 'centos-7-x86_64', 'centos-8-x86_64', 'oracle-5-x86_64', 'oracle-6-x86_64', 'oracle-7-x86_64', 'scientific-6-x86_64', 'scientific-7-x86_64', 'debian-8-x86_64', 'debian-9-x86_64', 'debian-10-x86_64', 'sles-11-x86_64', 'sles-12-x86_64', 'sles-15-x86_64', 'ubuntu-1404-x86_64', 'ubuntu-1604-x86_64', 'ubuntu-1804-x86_64', 'win-2008r2-x86_64', 'win-2012r2-x86_64', 'win-2016-core-x86_64', 'win-2019-core-x86_64', 'win-10-pro-x86_64']
```

You can then provision a list of targets from that file:

```bash
# This will spin up all the nodes defined in the `release_checks` key via VMPooler
pdk bundle exec rake 'litmus:provision_list[release_checks]'
# This will spin up the three nodes listed in the `vagrant` key via Vagrant.
# Note that it will also turn the listed key-value pairs in `params` into
# the environment variables and enable the task to leverage them.
pdk bundle exec rake 'litmus:provision_list[vagrant]'
```

<a name="agent"/>

## Installing a Puppet agent

Install an agent on the provisioned targets using the [Puppet Agent module](https://github.com/puppetlabs/puppetlabs-puppet_agent). The tasks in this module allow you to install different versions of the Puppet agent, on  different OSes.

Use the following command to install an agent on a single target or on all the targets in the `spec/fixtures/litmus_inventory.yaml` file. Note that agents are installed in parallel when running against multiple targets.

Install an agent on a target using the following commands:

```
# Install the latest Puppet agent on a specific target
pdk bundle exec rake 'litmus:install_agent[gn55owqktvej9fp.delivery.puppetlabs.net]'

# Install the latest Puppet agent on all targets
pdk bundle exec rake "litmus:install_agent"

# Install Puppet 5 on all targets
pdk bundle exec rake 'litmus:install_agent[puppet5]'

```

<a name="module"/>

## Installing a module

Using PDK and Bolt, the `rake litmus:install_module` command builds and installs a module on the target.

For example:

```
pdk bundle exec rake "litmus:install_module"
```

If you need multiple modules on the target system (e.g. fixtures pulled down through `pdk bundle exec rake spec_prep`, or a previous unit test run):

```
pdk bundle exec rake "litmus:install_modules_from_directory[spec/fixtures/modules]"
```

<a name="test"/>

## Running tests

There are several options for running tests. Litmus primarily uses [serverspec](https://serverspec.org/), though you can use other testing tools.

When running tests with Litmus, you can:
* Run all tests against a single target.
* Run all tests against all targets in parallel.
* Run a single test against a single target.

An example running all tests against a single target:

```
# On Linux/MacOS:
TARGET_HOST=lk8g530gzpjxogh.delivery.puppetlabs.net pdk bundle exec rspec ./spec/acceptance
TARGET_HOST=localhost:2223 pdk bundle exec rspec ./spec/acceptance
# On Windows:
$ENV:TARGET_HOST = 'lk8g530gzpjxogh.delivery.puppetlabs.net'
pdk bundle exec rspec ./spec/acceptance
```

An example running a specific test against a single target:

```
# On Linux/MacOS:
TARGET_HOST=lk8g530gzpjxogh.delivery.puppetlabs.net pdk bundle exec rspec ./spec/acceptance/test_spec.rb:21
TARGET_HOST=localhost:2223 pdk bundle exec rspec ./spec/acceptance/test_spec.rb:21
# On Windows:
$ENV:TARGET_HOST = 'lk8g530gzpjxogh.delivery.puppetlabs.net'
pdk bundle exec rspec ./spec/acceptance/test_spec.rb:21
```

An example running all tests against all targets, as specified in the `spec/fixtures/litmus_inventory.yaml` file:

```
pdk bundle exec rake litmus:acceptance:parallel
```

An example running all tests against localhost. Note that this is only recommended if you are familiar with the code base, as tests may have unexpected side effects on your local machine.

```
pdk bundle exec rake litmus:acceptance:localhost
```

For more test examples, see [run_tests task](https://github.com/puppetlabs/provision/wiki#run_tests) or [run tests plan](https://github.com/puppetlabs/provision/wiki#tests_against_agents)

<a name="teardown"/>

## Removing provisioned systems

Use the commands below to clean up provisioned systems after running tests. Specify whether to to remove an individual target or all the targets in the `spec/fixtures/litmus_inventory.yaml` file.

```
# Tear down a specific target vm
pdk bundle exec rake "litmus:tear_down[c985f9svvvu95nv.delivery.puppetlabs.net]"

# Tear down a specific target running locally
pdk bundle exec rake "litmus:tear_down[localhost:2222]"

# Tear down all targets in `spec/fixtures/litmus_inventory.yaml` file
pdk bundle exec rake "litmus:tear_down"
```
