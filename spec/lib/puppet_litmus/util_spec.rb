# frozen_string_literal: true

require 'spec_helper'
load File.expand_path('../../../lib/puppet_litmus/util.rb', __dir__)

RSpec.describe PuppetLitmus::Util do
  context 'when using interpolate_powershell' do
    let(:command) { 'foo' }
    let(:encoded) { Base64.strict_encode64(command.encode('UTF-16LE')) }

    it 'interpolates the command' do
      expect(described_class.interpolate_powershell(command)).to eql("powershell.exe -NoProfile -EncodedCommand #{encoded}")
      expect(described_class.interpolate_powershell(command)).not_to match(/#{command}/)
    end
  end
end
