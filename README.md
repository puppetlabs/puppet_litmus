# solid-waffle

## Overview
Providing a simple command line tool for puppet content creators, to enable simple and complex test deployments.

## How-to
### Using it in a module
gemfile
```
gem 'solid_waffle', git: 'git@github.com:puppetlabs/solid-waffle.git'
```
Rakefile
```
require 'solid_waffle/rake_tasks'
```
spec/spec_helper_acceptance.rb
```
require 'serverspec'
require 'solid_waffle'
include SolidWaffle

set :backend, :ssh

options = Net::SSH::Config.for(host)
options[:user] = 'root'
host = ENV['HOSTY']

set :host,        options[:host_name] || host
set :ssh_options, options
```

### Steps (each step is optional)

1. provision machines - specify number of machines / and OS, along with the mechanism eg azure / docker / vmpooler
2. pre-setup - disable apt / configure firewall 
3. install puppet - PE / FOSS / Bolt
4. pre-test - build and install module
5. snapshot - allow rollbacks in vmpooler / vagrant
6. test - run rspec / inspec / serverspec / puppet code as tests
7. tear-down - decommission machines

## Technologies used
Just enough rake goodness to bind puppet code and bolt tasks to our will. 
Leveraging content from the forge and existing test frameworks.

## Other Resources

* [Is it Worth the Time?](https://xkcd.com/1205/)

# Real world example & steps

Needs the pdk installed, to build the module. 'bundle exec rake --tasks' is your friend.

```
git clone git@github.com:puppetlabs/puppetlabs-motd.git
git remote add tphoney git@github.com:tphoney/puppetlabs-motd.git
git rebase tphoney/solid-waffle
bundle install --path .bundle/gems/
bundle exec rake 'waffle:provision[vmpooler, centos-7-x86_64]'
bundle exec rake 'waffle:provision[vmpooler, win-2012r2-x86_64]'
bundle exec rake waffle:install_agent
bundle exec rake waffle:install_module
bundle exec rake acceptance:all -j10 -m
```
