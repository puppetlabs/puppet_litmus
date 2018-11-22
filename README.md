# solid-waffle

## Overview
Providing a simple command line tool for puppet content creators, to enable simple and complex test deployments. It uses https://github.com/puppetlabs/waffle_provision for provisioning

## How-to
### Using it in a module

.fixtures.yml

```
---
fixtures:
  repositories:
    facts: 'git://github.com/puppetlabs/puppetlabs-facts.git'
    puppet_agent: 'git://github.com/puppetlabs/puppetlabs-puppet_agent.git'
    waffle_provision: 'git@github.com:puppetlabs/waffle_provision.git'
```

Gemfile

```
gem 'solid_waffle', git: 'git@github.com:puppetlabs/solid-waffle.git'
gem 'pdk', git: 'https://github.com/tphoney/pdk.git', branch: 'pin_cri'
```

Rakefile

```
require 'solid_waffle/rake_tasks'
```

spec/spec_helper_acceptance.rb

```
# frozen_string_literal: true

require 'serverspec'
require 'solid_waffle'
include SolidWaffle

if ENV['TARGET_HOST'].nil?
  puts 'Running tests against this machine !'
else
  puts "TARGET_HOST #{ENV['TARGET_HOST']}"
  # load inventory
  inventory_hash = inventory_hash_from_inventory_file
  node_config = config_from_node(inventory_hash, ENV['TARGET_HOST'])

  if target_in_group(inventory_hash, ENV['TARGET_HOST'], 'ssh_nodes')
    set :backend, :ssh
    options = Net::SSH::Config.for(host)
    options[:user] = node_config.dig('ssh', 'user') unless node_config.dig('ssh', 'user').nil?
    options[:port] = node_config.dig('ssh', 'port') unless node_config.dig('ssh', 'port').nil?
    options[:password] = node_config.dig('ssh', 'password') unless node_config.dig('ssh', 'password').nil?
    host = if ENV['TARGET_HOST'].include?(':')
             ENV['TARGET_HOST'].split(':').first
           else
             ENV['TARGET_HOST']
           end
    set :host,        options[:host_name] || host
    set :ssh_options, options
  elsif target_in_group(inventory_hash, ENV['TARGET_HOST'], 'winrm_nodes')
    require 'winrm'

    set :backend, :winrm
    set :os, family: 'windows'
    user = node_config.dig('winrm', 'user') unless node_config.dig('winrm', 'user').nil?
    pass = node_config.dig('winrm', 'password') unless node_config.dig('winrm', 'password').nil?
    endpoint = "http://#{ENV['TARGET_HOST']}:5985/wsman"

    opts = {
      user: user,
      password: pass,
      endpoint: endpoint,
      operation_timeout: 300,
    }

    winrm = WinRM::Connection.new opts
    Specinfra.configuration.winrm = winrm
  end
end
```

### Steps (each step is optional)

1. waffle:provision - specify number of machines / and OS, along with the mechanism eg azure / docker / vmpooler
2. waffle:install_agent 
3. install_module 
4. acceptance:all

## Technologies used
Just enough rake goodness to bind puppet code and bolt tasks to our will. 
Leveraging content from the forge and existing test frameworks.

## Other Resources

* [Is it Worth the Time?](https://xkcd.com/1205/)

## issues

* only supports puppet 5 and 6
* bolt and pdk gems do not play well because of CRI, 'https://github.com/tphoney/pdk.git', branch: 'pin_cri'

# Real world example & steps

'bundle exec rake --tasks' is your friend.

```
git clone git@github.com:puppetlabs/puppetlabs-motd.git
cd puppetlabs-motd
git remote add tphoney git@github.com:tphoney/puppetlabs-motd.git
git rebase tphoney/solid-waffle
bundle install --path .bundle/gems/
bundle exec rake 'waffle:provision[vmpooler, centos-7-x86_64]'
bundle exec rake 'waffle:provision[vmpooler, win-2012r2-x86_64]'

bundle exec rake waffle:install_agent
bundle exec rake waffle:install_module

# run tests in parallel
bundle exec rake acceptance:all -j10 -m 

# return images to pool
bundle exec rake waffle:tear_down
```
