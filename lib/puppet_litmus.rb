# frozen_string_literal: true

# Helper methods for testing puppet content
module PuppetLitmus; end

require 'bolt_spec/run'
require 'puppet_litmus/inventory_manipulation'
require 'puppet_litmus/serverspec'

# Helper methods for testing puppet content
module PuppetLitmus
  include BoltSpec::Run
  include PuppetLitmus::InventoryManipulation
  include PuppetLitmus::Serverspec
end
