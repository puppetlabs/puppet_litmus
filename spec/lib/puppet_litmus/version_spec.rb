# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PuppetLitmus do # rubocop:disable RSpec/FilePath
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
    expect(described_class::VERSION).to be_a_kind_of(String)
  end
end
