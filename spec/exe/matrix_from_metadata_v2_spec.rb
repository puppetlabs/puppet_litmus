# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'matrix_from_metadata_v2' do
  context 'without arguments' do
    let(:github_output) { Tempfile.new('github_output') }
    let(:github_output_content) { github_output.read }
    let(:result) { run_matrix_from_metadata_v2 }

    before do
      ENV['GITHUB_OUTPUT'] = github_output.path
    end

    it 'run successfully' do
      expect(result.status_code).to eq 0
    end

    it 'generates the matrix' do
      expect(result.stdout).to include('::warning::Cannot find image for Ubuntu-14.04')
      expect(github_output_content).to include(
        [
          'matrix={',
          '"platforms":[',
          '{"label":"CentOS-6","provider":"provision::docker","image":"litmusimage/centos:6"},',
          '{"label":"RedHat-8","provider":"provision::provision_service","image":"rhel-8"},',
          '{"label":"Ubuntu-18.04","provider":"provision::docker","image":"litmusimage/ubuntu:18.04"}',
          '],',
          '"collection":[',
          '"puppet7-nightly","puppet8-nightly"',
          ']',
          '}'
        ].join
      )
      expect(github_output_content).to include(
        'spec_matrix={"include":[{"puppet_version":"~> 7.0","ruby_version":2.7},{"puppet_version":"~> 8.0","ruby_version":3.2}]}'
      )
      expect(result.stdout).to include("Created matrix with 8 cells:\n  - Acceptance Test Cells: 6\n  - Spec Test Cells: 2")
    end
  end

  context 'with --exclude-platforms ["ubuntu-18.04"]' do
    let(:github_output) { Tempfile.new('github_output') }
    let(:github_output_content) { github_output.read }
    let(:result) { run_matrix_from_metadata_v2({ '--exclude-platforms' => ['ubuntu-18.04'] }) }

    before do
      ENV['GITHUB_OUTPUT'] = github_output.path
    end

    it 'run successfully' do
      expect(result.status_code).to eq 0
    end

    it 'generates the matrix without excluded platforms' do
      expect(result.stdout).to include('::warning::Cannot find image for Ubuntu-14.04')
      expect(result.stdout).to include('::warning::Ubuntu-18.04 was excluded from testing')
      expect(github_output_content).to include(
        [
          'matrix={',
          '"platforms":[',
          '{"label":"CentOS-6","provider":"provision::docker","image":"litmusimage/centos:6"},',
          '{"label":"RedHat-8","provider":"provision::provision_service","image":"rhel-8"}',
          '],',
          '"collection":[',
          '"puppet7-nightly","puppet8-nightly"',
          ']',
          '}'
        ].join
      )
      expect(github_output_content).to include(
        'spec_matrix={"include":[{"puppet_version":"~> 7.0","ruby_version":2.7},{"puppet_version":"~> 8.0","ruby_version":3.2}]}'
      )
      expect(result.stdout).to include("Created matrix with 6 cells:\n  - Acceptance Test Cells: 4\n  - Spec Test Cells: 2")
    end
  end

  context 'with --exclude-platforms \'["ubuntu-18.04","redhat-8"]\'' do
    let(:github_output) { Tempfile.new('github_output') }
    let(:github_output_content) { github_output.read }
    let(:result) { run_matrix_from_metadata_v2({ '--exclude-platforms' => ['ubuntu-18.04', 'redhat-8'] }) }

    before do
      ENV['GITHUB_OUTPUT'] = github_output.path
    end

    it 'run successfully' do
      expect(result.status_code).to eq 0
    end

    it 'generates the matrix without excluded platforms' do
      expect(result.stdout).to include('::warning::Cannot find image for Ubuntu-14.04')
      expect(result.stdout).to include('::warning::Ubuntu-18.04 was excluded from testing')
      expect(result.stdout).to include('::warning::RedHat-8 was excluded from testing')
      expect(github_output_content).to include(
        [
          'matrix={',
          '"platforms":[',
          '{"label":"CentOS-6","provider":"provision::docker","image":"litmusimage/centos:6"}',
          '],',
          '"collection":[',
          '"puppet7-nightly","puppet8-nightly"',
          ']',
          '}'
        ].join
      )
      expect(github_output_content).to include(
        'spec_matrix={"include":[{"puppet_version":"~> 7.0","ruby_version":2.7},{"puppet_version":"~> 8.0","ruby_version":3.2}]}'
      )
      expect(result.stdout).to include("Created matrix with 4 cells:\n  - Acceptance Test Cells: 2\n  - Spec Test Cells: 2")
    end
  end
end
