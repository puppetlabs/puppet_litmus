# frozen_string_literal: true

# Helper methods for testing puppet content
module PuppetLitmus; end

require 'bolt_spec/run'
require 'puppet_litmus/inventory_manipulation'
require 'puppet_litmus/puppet_helpers'
require 'puppet_litmus/rake_helper'
require 'puppet_litmus/spec_helper_acceptance'

# Helper methods for testing puppet content
module PuppetLitmus
  # Container class for BoltSpec::Run methods to avoid leaking them via include
  class BoltSpecRun
    include BoltSpec::Run
  end

  # Method for shortening the reference to the BoltSpec::Run methods, memoized.
  #
  # @return [PuppetLitmus::BoltSpecRun] instance of the bolt_spec container class
  def self.bolt
    @bolt ||= BoltSpecRun.new
  end

  include PuppetLitmus::InventoryManipulation
  include PuppetLitmus::PuppetHelpers
  include PuppetLitmus::RakeHelper
end
