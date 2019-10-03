# frozen_string_literal: true

require 'spec_helper'
load File.expand_path('../../../lib/puppet_litmus/version.rb', __dir__)

include PuppetLitmus # rubocop:disable Style/MixinUsage

RSpec.describe PuppetLitmus do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
    expect(described_class::VERSION).to be_a_kind_of(String)
  end
end
