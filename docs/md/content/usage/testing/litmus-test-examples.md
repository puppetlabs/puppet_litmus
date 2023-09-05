---
layout: page
title: Example tests
description: A list of example Litmus tests.
---

These are some common examples you can use in your tests. Take note of the differences between beaker-rspec style testing and Litmus.

## Testing Puppet code

The following example tests that your Puppet code works. Take note of the repeatable pattern.

```ruby
require 'spec_helper_acceptance'

describe 'a feature', if: ['debian', 'redhat', 'ubuntu'].include?(os[:family]) do
  let(:pp) do
    <<-MANIFEST
      include feature::some_class
    MANIFEST
  end

  it 'applies idempotently' do
    idempotent_apply(pp)
  end

  describe file("/etc/feature.conf") do
    it { is_expected.to be_file }
    its(:content) { is_expected.to match %r{key = default value} }
  end

  describe port(777) do
    it { is_expected.to be_listening }
  end
end
```

## Testing manifest code for idempotency

The `idempotent_apply` helper function runs the given manifest twice and will test that the first run doesn't have errors and the second run doesn't have changes. For many regular modules that already will give good confidence that it is working:

```ruby
pp = 'class { "mysql::server": }'
idempotent_apply(pp)
```

## Running shell commands

To run a shell command and test it's output:

```ruby
expect(run_shell('/usr/local/sbin/mysqlbackup.sh').stderr).to eq('')
```

### Serverspec Idioms

An example of a serverspec declaration:

```ruby
describe command('/usr/local/sbin/mysqlbackup.sh') do
  its(:stderr) { should eq '' }
end
```

## Checking facts

With Litmus, you can use the serverspec functions — these are cached so are quick to call. For example:

```ruby
os[:family]
```

or

```ruby
host_inventory['facter']['os']['release']
```

For more information, see the [serverspec docs](https://serverspec.org/host_inventory.html).

## Debugging tests

There is a known issue when running certain commands from within a pry session. To debug tests, use the following pry-byebug gem:

```ruby
gem  'pry-byebug', '> 3.4.3'
```

## Setting up Travis and Appveyor

To see this running on CI, enable the `use_litmus` flags for Travis CI and/or Appveyor.
