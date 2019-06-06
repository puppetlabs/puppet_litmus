# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PuppetLitmus::Serverspec do
  class DummyClass
  end
  let(:dummy_class) do
    dummy_class = DummyClass.new
    dummy_class.extend(described_class)
    dummy_class
  end

  context 'with idempotent_apply' do
    let(:manifest) do
      "include '::doot'"
    end

    it 'calls all functions' do
      expect(dummy_class).to receive(:create_manifest_file).with(manifest).and_return('/bla.pp')
      expect(dummy_class).to receive(:apply_manifest).with(nil, catch_failures: true, manifest_file_location: '/bla.pp')
      expect(dummy_class).to receive(:apply_manifest).with(nil, catch_changes: true, manifest_file_location: '/bla.pp')
      dummy_class.idempotent_apply(manifest)
    end
  end
end
