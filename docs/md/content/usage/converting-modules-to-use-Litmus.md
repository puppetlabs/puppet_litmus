---
layout: page
title: Quick Start Guide
description: Learn how to use Litmus in your Puppet modules.
weight: 1
---

The following example walks you through enabling Litmus testing in a module.

The process involves editing or adding code to the following files:

1. The `Gemfile`
2. The `Rakefile`
3. The`.fixtures.yml` file
4. The `spec_helper_acceptance.rb` file
5. The `spec_helper_acceptance_local.rb` file

## Before you begin

This guide assumes your module is compatible with [Puppet Development Kit (PDK)](https://puppet.com/docs/pdk/1.x/pdk.html),
meaning it was either created with `pdk new module` or has been converted to use PDK using the `pdk convert` command.
To verify that your module is compatible with PDK, look in the modules `metadata.json` file and see whether there is an entry that states the PDK version.
It will look something like `"pdk-version": "1.18.0"`.
The PDK ships litmus as an experimental component.

To enable it, follow the steps below.

## 1. Add required development dependencies

Inside the root directory of your module, add the following entries to the `.fixtures.yml`:

```yaml
---
fixtures:
  repositories:
    facts: 'https://github.com/puppetlabs/puppetlabs-facts.git'
    puppet_agent: 'https://github.com/puppetlabs/puppetlabs-puppet_agent.git'
    provision: 'https://github.com/puppetlabs/provision.git'
```

## 2. Create the `spec/spec_helper_acceptance.rb` file

Inside the `spec` folder of the module, create a `spec_helper_acceptance.rb` file with the following contents:

```ruby
# frozen_string_literal: true

require 'puppet_litmus'
PuppetLitmus.configure!

require 'spec_helper_acceptance_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_acceptance_local.rb'))
```

This file will later become managed by the PDK. For local changes, see the next step.

## 3. Create the `spec/spec_helper_acceptance_local.rb` file

***Optional:*** For module-specific methods to be used during acceptance testing, create a `spec/spec_helper_acceptance_local.rb` file. This will be loaded at the start of each test run. If you need to use any of the Litmus methods in this file, include Litmus as a singleton class:

```ruby
# frozen_string_literal: true
require 'singleton'

class Helper
  include Singleton
  include PuppetLitmus
end

def some_helper_method
  Helper.instance.bolt_run_script('path/to/file')
end
```

## 4. Add tests to `spec/acceptance`

You can find [litmus test examples](/content-and-tooling-team/docs/litmus/usage/testing/litmus-test-examples/) on their own page.
