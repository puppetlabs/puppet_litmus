---
layout: page
title: Acceptance tests
description: Acceptance testing with Litmus.
---

The following example walks you through running an acceptance test on the [MoTD](https://github.com/puppetlabs/puppetlabs-motd) module.

The process involves these steps:

1. Clone the MoTD module from GitHub.
1. Provision a CentOS Docker image.
1. Install a Puppet 6 agent on the CentOS image.
1. Install the MoTD module on the CentOS image.
1. Run the MoTD acceptance tests.
1. Remove the Docker image.

## Before you begin

Ensure you have installed the following:

* [Docker](https://runnable.com/docker/getting-started/).
	* To check whether you already have Docker, run `docker --version` from the command line.
	* To check Docker is working, run `docker run centos:7 ls` in your terminal. You should see a list of folders in the CentOS image.
* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
	* To check  where you already have git, run `git --version` in your terminal.
* [Puppet Development Kit (PDK)](https://puppet.com/docs/pdk/3.x/pdk_install.html).
	* To check whether you already have PDK, run `pdk --version` from the command line. Note that you need version `1.17.0` or later. If not, then following the [installation instructions](https://puppet.com/docs/pdk/3.x/pdk_install.html).


## 1. Clone the MoTD module from GitHub.

From  the command line, clone the Litmus branch of MoTD module:

```bash
git clone https://github.com/puppetlabs/puppetlabs-motd.git
```

You now have a local copy of the module on your machine. In this example, you can work  off the master branch.

Change directory to the MoTD module

```bash
cd puppetlabs-motd
```

## 2. Install the necessary gems.

The MoTD module relies on a number of gems. To install these on your machine, run the following command:

```bash
pdk bundle install
```

## 3. Provision a CentOS Docker image

Provision a CentOS stream 9 image in a Docker container to be the target you will test against

To provision the CentOS stream 9 target (or any OS of your choice), run the following command:

```bash
pdk bundle exec rake 'litmus:provision[docker, litmusimage/centos:stream9]'
```

> Note: Provisioning is extensible. If your preferred provisioner is missing, let us know by raising an issue on the [provision repo](https://github.com/puppetlabs/provision/issues) or submitting a [PR](https://github.com/puppetlabs/provision/pulls).

The last lines of the output should look like:

```bash
Provisioning centos:stream9 using docker provisioner.[✔]
localhost:2222, centos:stream9
```

To check that it worked, run `docker ps` and you should see output similar to:

```bash
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                  NAMES
7b12b616cf65        centos:stream9      "/bin/bash"         4 minutes ago       Up 4 minutes        0.0.0.0:2222->22/tcp   centos_stream9-2222
```

Note that the provisioned targets will be in the `spec/fixtures/litmus_inventory.yaml` file. Litmus creates this file in your working directory. If you run `cat spec/fixtures/litmus_inventory.yaml`, you should see the targets you just created. For example:

```yaml
# litmus_inventory.yaml
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
      container_name: centos_stream9-2222
      platform: centos:stream9
- name: winrm_nodes
  targets: []
```

## 4. Install Puppet agent on your target

To install the latest version of Puppet agent on the CentOS Docker image, run the following command:

```bash
pdk bundle exec rake litmus:install_agent
```

Use Bolt to verify that you have installed the agent on the target. Run the following command:

```bash
pdk bundle exec bolt command run 'puppet --version' --targets localhost:2222 --inventoryfile spec/fixtures/litmus_inventory.yaml
```

Note that `localhost:2222` is the name of the node in the spec/fixtures/litmus_inventory.yaml file. You should see output with the version of the Puppet agent that was installed:

```bash
bolt command run 'puppet --version' --targets localhost:2222 --inventoryfile spec/fixtures/litmus_inventory.yaml
```

Running the command will produce output similar to this:

```bash
Started on localhost:2222...
Finished on localhost:2222:
  STDOUT:
    6.13.0
Successful on 1 target: localhost:2222
Ran on 1 target in 1.72 sec
```

If you want to install a specific version of puppet you can use the following command:

```bash
pdk bundle exec rake 'litmus:install_agent[puppet8-nightly]
```

Examples of other versions you can pass in are: 'puppet', 'puppet-nightly', 'puppet7', 'puppet7-nightly'.

## 5. Install the MoTD module on the CentOS image

To install the MoTD module on the CentOS image, run the following command from inside your working directory:

```bash
pdk bundle exec rake litmus:install_module
```

*Note: If you are interactively modifying code and testing, this step must be run after your changes are made and before you run your tests.*

You will see output similar to:

```bash
➜  puppetlabs-motd git:(main) pdk bundle exec rake litmus:install_module
pdk (INFO): Using Ruby 3.2.0
pdk (INFO): Using Puppet 8.1.0
Building '/Users/paula/workspace/puppetlabs-mysql' into '/Users/paula/workspace/puppetlabs-motd/pkg'
Built '/Users/paula/workspace/puppetlabs-motd/pkg/puppetlabs-motd-11.0.3.tar.gz'
Installed '/Users/paula/workspace/puppetlabs-motd/pkg/puppetlabs-motd-11.0.3.tar.gz' on
```

Use Bolt to verify that you have installed the MoTD module. Run the following command:

```bash
pdk bundle exec bolt command run 'puppet module list' --targets localhost:2222 -i spec/fixtures/litmus_inventory.yaml
```

The output should look similar to:

```bash
Started on localhost...
Finished on localhost:
  STDOUT:
    /etc/puppetlabs/code/environments/production/modules
    ├── puppetlabs-motd (v2.1.2)
    ├── puppetlabs-registry (v2.1.0)
    ├── puppetlabs-stdlib (v5.2.0)
    └── puppetlabs-translate (v1.2.0)
    /etc/puppetlabs/code/modules (no modules installed)
    /opt/puppetlabs/puppet/modules (no modules installed)
Successful on 1 node: localhost:2222
Ran on 1 node in 1.11 seconds
Started on localhost:2222...
Finished on localhost:2222:
  STDOUT:
    /etc/puppetlabs/code/environments/production/modules
    ├── puppetlabs-motd (v4.1.0)
    ├── puppetlabs-registry (v3.1.0)
    ├── puppetlabs-stdlib (v6.2.0)
    └── puppetlabs-translate (v2.1.0)
    /etc/puppetlabs/code/modules (no modules installed)
    /opt/puppetlabs/puppet/modules (no modules installed)
Successful on 1 target: localhost:2222
Ran on 1 target in 1.77 sec
```

Note that you have also installed the MoTD module's dependent modules.

## 6. Run the MoTD acceptance tests

To run acceptance tests with Litmus, run the following command from your working directory:

```bash
pdk bundle exec rake litmus:acceptance:parallel
```

This command executes the acceptance tests in the [acceptance folder](https://github.com/puppetlabs/puppetlabs-motd/tree/main/spec/acceptance) of the module. If the tests have run successfully, you will see output similar to (Note it will look like it has stalled but is actually running tests in the background, please be patient and the output will appear when the tests are complete:

```bash
+ [✔] Running against 1 targets.
|__ [✔] localhost:2222, centos:stream9
================
localhost:2222, centos:stream9
......

Finished in 42.95 seconds (files took 10.15 seconds to load)
6 examples, 0 failures

pid 1476 exit 0
Successful on 1 nodes: ["localhost:2222, centos:stream9"]
```

## 7. Remove the Docker image

Now that you have completed your tests, you can remove the Docker image with the Litmus tear down command:

```bash
pdk bundle exec rake litmus:tear_down
```

You should see JSON output, similar to:

```bash
localhost:2222: success
```

To verify that the target has been removed, run `docker ps` from the command line. You should see that it's no longer running.

## Next steps

The MoTD shows you how to use Litmus to acceptance test an existing module. As you scale up your acceptance testing, you will need to write your own acceptance tests. Try out the following:

* Provision more than one system, for example, `pdk bundle exec rake 'litmus:provision[docker, litmusimage/debian:12]'`. Note that you will need to re-run the `install_agent` and `install_module` command if you want to run tests.
* Look at the inventory file and take note of the ssh connection information
* ssh into the CentOS box when you know the password, for example, `ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@localhost -p 2222`, or use Bolt as shown in the example.
* ssh into the CentOS box without a password, run `docker ps`, take note of the Container Name and then run `docker exec -it litmusimage_centos_stream9-2222 '/bin/bash'` in this example litmusimage_centos_stream9-2222 is the Container Name.

> Note: We have moved all our PR testing to public pipelines to make contributing to Puppet supported modules a better experience. Check out our [Github Action templates](https://github.com/puppetlabs/cat-github-actions/tree/main/.github/workflows). All of our testing is now ran in the one place.
