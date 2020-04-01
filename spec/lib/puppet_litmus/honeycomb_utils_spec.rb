# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PuppetLitmus::HoneycombUtils do
  describe '::add_platform_field(inventory_hash, target_node_name)' do
    let(:current_span) { instance_double('Honeycomb::Span', 'current_span') }
    let(:inventory_hash) { { 'groups' => [{ 'name' => 'ssh_nodes', 'targets' => [{ 'uri' => 'localhost:2222', 'facts' => { 'platform' => 'litmusimage/centos:7' } }] }] } }

    before :each do
      allow(Honeycomb).to receive(:current_span).with(no_args).and_return(current_span)
    end

    context 'with an existing target' do
      it do
        expect(current_span).to receive(:add_field).with('litmus.platform', 'litmusimage/centos:7')
        described_class.add_platform_field(inventory_hash, 'localhost:2222')
      end
    end

    context 'with a non-existing target' do
      it do
        expect { described_class.add_platform_field(inventory_hash, 'NOPE') }.to raise_error RuntimeError, 'No facts were found for NOPE'
      end
    end
  end
end
