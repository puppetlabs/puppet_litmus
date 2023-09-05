---
title: Helper functions
layout: page
description: Learn all about Litmus functions.
---

Inside of the Litmus gem, there are three distinct sets of functions:

* Rake tasks for the CLI that allows you to use the Litmus commands (provision, install an agent, install a module and run tests.). Run `pdk bundle exec rake -T` to get a list of available rake tasks.
* Helper functions for serverspec / test. These apply manifests or run shell commands. For more information, see [Puppet Helpers](https://www.rubydoc.info/gems/puppet_litmus/PuppetLitmus/PuppetHelpers)
* Helper Functions for Bolt inventory file manipulation. For more information, see [Inventory Manipulation](https://www.rubydoc.info/gems/puppet_litmus/PuppetLitmus/InventoryManipulation).
