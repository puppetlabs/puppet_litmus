---
layout: page
title: Tools
description: Learn the tools Litmus uses.
---

Litmus wraps functionality from other tools, providing a rake interface for you to develop modules.

* [Bolt](https://github.com/puppetlabs/bolt) is an open source orchestration tool that automates the manual work it takes to maintain your infrastructure. Litmus is built on top of bolt, so it natively handles SSH, WinRM and Docker. The inventory file specifies the protocol to use for each target, when using litmus this can be found in `spec/fixtures/litmus_inventory.yaml`, along with connection specific information. Litmus uses Bolt to execute module tasks.
* [Serverspec](https://serverspec.org/) lets you check your servers are configured correctly.
* Puppet Development Kit (PDK) provides a complete module structure, templates for classes, defined types, and tasks, and a testing infrastructure.
* [Litmus Image](https://github.com/puppetlabs/litmus_image) is a group of Docker build files. They are specifically designed to set up systemd/upstart on various nix images. This is a prerequisite for testing services with Puppet in Docker images.`litmus_image` generates an inventory file, that contains connection information for each system instance. This is used by subsequent commands or by rspec.

These tools are built into the Litmus commands:

#### Provision

To provision systems we created a [module](https://github.com/puppetlabs/provision) that will provision containers / images / hardware in ABS (internal to Puppet) and Docker instances. Provision is extensible, so other provisioners can be added - please raise an [issue](https://github.com/puppetlabs/provision/issues) on the Provision repository, or create your own and submit a [PR](https://github.com/puppetlabs/provision/pulls)!

rake task -> litmus -> bolt -> provision -> docker
                                         -> vagrant
                                         -> abs (internal)
                                         -> vmpooler (internal)

#### Installing an agents

rake task -> bolt -> puppet_agent module

#### Installing modules

PDK builds the module tar file and is copied to the target using Bolt. On the target machine, run `puppet module install`, specifying the tar file. This installs the dependencies listed in the metadata.json of the built module.

rake task -> pdk -> bolt

#### Running tests

rake task -> serverspec -> rspec

#### Tearing down targets

rake task -> bolt provision -> docker
                            -> abs (internal)
                            -> vmpooler
