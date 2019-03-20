# Litmus

## Overview
Litmus provides a simple command line tool for Puppet content creators, to enable both simple and complex test deployments against specifically configured target systems. It is available as a gem, and can be installed by running ```gem install puppet-litmus```.

Litmus allows Puppet module developers to:
* provision targets to test against,
* install the Puppet Agent, 
* install a module,
* run tests, and
* tear down the infrastructure.

The tool facilitates parallel test runs, running tests in isolation, and each step is standalone, allowing other operations between test runs, such as debugging, or configuration updates on the test targets.

## Documentation

All our documentation is currently available in the [Wiki](https://github.com/puppetlabs/puppet_litmus/wiki).

* [Overview](https://github.com/puppetlabs/puppet_litmus/wiki/Overview-of-Litmus) of the main functions
* [Architecture](https://github.com/puppetlabs/puppet_litmus/wiki/Architecture-of-puppet-litmus) with an explanation of what's going on under the hood
* [Step-by-step guide](https://github.com/puppetlabs/puppet_litmus/wiki/Tutorial:-use-Litmus-to-execute-acceptance-tests-with-a-sample-module-(MoTD)) of how to use Litmus with the popular and simple [MoTD Puppet module](https://forge.puppet.com/puppetlabs/motd).
* [How to guide](https://github.com/puppetlabs/puppet_litmus/wiki/Converting-a-module-to-use-Litmus) walking through how to use Litmus in a module

## Known issues

### PDK and Bolt dependencies infers support on Ruby and Puppet versions

We are actively working towards the point that where we declare our gem dependencies for PDK and Bolt gems in the puppet_litmus gemspec file [here](https://github.com/puppetlabs/puppet_litmus/blame/master/puppet_litmus.gemspec#L23)

Bolt has a hard dependency on Puppet 6, and CRI 2.15.1 which is ruby version specific
PDK depends on CRI 2.10.0 which is ruby version specific

We have work in progress to create a pathway through this. A fix is up for PDK, which allows CRI 2.15 and 2.10 to be used (here)[https://github.com/puppetlabs/pdk/pull/638]. This also allows the use of multiple ruby versions.

A PR (here)[https://github.com/puppetlabs/puppetlabs-motd/pull/200] shows what needs to happen within a module, to use litmus for puppet 5 unit tests, and puppet 6 unit tests. Also for running acceptance tests against puppet 5 and puppet 6 with litmus.

(Gem changes for a module)[https://github.com/puppetlabs/puppetlabs-motd/blob/29d8c9b0ceceb4b0114a66077ce0f473a49481a5/Gemfile#L34-L39] it only installs litmus if your are running puppet 6 and system tests. Also to use a version of the pdk that has the CRI fixes. You can still test against puppet 5 targets in acceptance tests. IF you want to run unit tests against the puppet 5 gem you will have to run something like (this)[https://github.com/puppetlabs/puppetlabs-motd/blob/29d8c9b0ceceb4b0114a66077ce0f473a49481a5/.travis.yml#L107]

Thank you for your patience. 

## Other Resources

* [Is it Worth the Time?](https://xkcd.com/1205/)
