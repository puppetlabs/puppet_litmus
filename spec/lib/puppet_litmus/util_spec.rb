# frozen_string_literal: true

require 'spec_helper'
load File.expand_path('../../../lib/puppet_litmus/util.rb', __dir__)

RSpec.describe PuppetLitmus::Util do
  context 'when using interpolate_powershell' do
    it 'interpolates the command' do
      expect(described_class.interpolate_powershell('foo')).to match(%r{powershell\.exe})
      expect(described_class.interpolate_powershell('foo')).to match(%r{NoProfile})
      expect(described_class.interpolate_powershell('foo')).to match(%r{EncodedCommand})
      expect(described_class.interpolate_powershell('foo')).not_to match(%r{foo})
    end
  end
end
