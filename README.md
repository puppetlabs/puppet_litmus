# solid-waddle

## Overview
Providing a simple command line tool for puppet content creators, to enable simple and complex test deployments.

## How-to
### Install
Add the following gems to your gemfile
bundle exec install 

### Steps

1. provision machines - specify number of machines / and OS, along with the mechanism eg azure / docker / vmpooler
2. pre-setup - disable apt / configure firewall 
3. install puppet - PE / FOSS / Bolt
4. pre-test - build and install module
5. snapshot - allow rollbacks in vmpooler / vagrant
6. test - run rspec / inspec / serverspec / puppet code as tests
7. tear down - decommission machines

### Technologies used
