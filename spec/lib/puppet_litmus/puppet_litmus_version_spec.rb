# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PuppetLitmus do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
    expect(described_class::VERSION).to be_a_kind_of(String)
  end
end
