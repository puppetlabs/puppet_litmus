# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'matrix_from_metadata_v3' do
  let(:github_output) { Tempfile.new('github_output') }
  let(:github_output_content) { github_output.read }
  let(:github_repository_owner) { nil }

  before do
    ENV['GITHUB_ACTIONS'] = '1'
    ENV['GITHUB_OUTPUT'] = github_output.path
    ENV['GITHUB_REPOSITORY_OWNER'] = github_repository_owner
  end

  context 'without arguments' do
    let(:result) { run_matrix_from_metadata_v3 }

    it 'run successfully' do
      expect(result.status_code).to eq 0
    end

    it 'generates the matrix' do
      matrix = [
        'matrix={',
        '"platforms":[',
        '{"label":"AmazonLinux-2","provider":"docker","arch":"x86_64","image":"litmusimage/amazonlinux:2","runner":"ubuntu-22.04"},',
        '{"label":"AmazonLinux-2023","provider":"docker","arch":"x86_64","image":"litmusimage/amazonlinux:2023","runner":"ubuntu-22.04"},',
        '{"label":"Ubuntu-18.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:18.04","runner":"ubuntu-22.04"},',
        '{"label":"Ubuntu-22.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:22.04","runner":"ubuntu-latest"}',
        '],',
        '"collection":[',
        '"puppetcore8-nightly"',
        ']',
        '}'
      ].join
      expect(result.stdout).to include(
        '::warning::CentOS-6 no provisioner found',
        '::warning::Ubuntu-14.04 no provisioner found',
        '::group::matrix',
        '::group::spec_matrix'
      )
      expect(github_output_content).to include(matrix)
      expect(github_output_content).to include('spec_matrix={"include":[{"puppet_version":"~> 8.0","ruby_version":3.2}]}')
    end
  end

  context 'with puppetlabs GITHUB_REPOSITORY_OWNER' do
    let(:result) { run_matrix_from_metadata_v3 }
    let(:github_repository_owner) { 'puppetlabs' }

    let(:matrix) do
      [
        'matrix={',
        '"platforms":[',
        '{"label":"AmazonLinux-2","provider":"docker","arch":"x86_64","image":"litmusimage/amazonlinux:2","runner":"ubuntu-22.04"},',
        '{"label":"AmazonLinux-2023","provider":"docker","arch":"x86_64","image":"litmusimage/amazonlinux:2023","runner":"ubuntu-22.04"},',
        '{"label":"RedHat-8","provider":"provision_service","arch":"x86_64","image":"rhel-8","runner":"ubuntu-latest"},',
        '{"label":"RedHat-9","provider":"provision_service","arch":"x86_64","image":"rhel-9","runner":"ubuntu-latest"},',
        '{"label":"RedHat-9-arm","provider":"provision_service","arch":"arm","image":"rhel-9-arm64","runner":"ubuntu-latest"},',
        '{"label":"Ubuntu-18.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:18.04","runner":"ubuntu-22.04"},',
        '{"label":"Ubuntu-22.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:22.04","runner":"ubuntu-latest"},',
        '{"label":"Ubuntu-22.04-arm","provider":"provision_service","arch":"arm","image":"ubuntu-2204-lts-arm64","runner":"ubuntu-latest"}',
        '],',
        '"collection":[',
        '"puppetcore8-nightly"',
        ']',
        '}'
      ].join
    end

    it 'run successfully' do
      expect(result.status_code).to eq 0
    end

    it 'generates the matrix' do
      expect(result.stdout).to include(
        '::warning::CentOS-6 no provisioner found',
        '::warning::Ubuntu-14.04 no provisioner found',
        '::group::matrix',
        '::group::spec_matrix'
      )
      expect(github_output_content).to include(matrix)
      expect(github_output_content).to include(
        'spec_matrix={"include":[{"puppet_version":"~> 8.0","ruby_version":3.2}]}'
      )
    end
  end

  context 'with argument --puppetlabs' do
    let(:result) { run_matrix_from_metadata_v3(['--puppetlabs']) }
    let(:matrix) do
      [
        'matrix={',
        '"platforms":[',
        '{"label":"AmazonLinux-2","provider":"docker","arch":"x86_64","image":"litmusimage/amazonlinux:2","runner":"ubuntu-22.04"},',
        '{"label":"AmazonLinux-2023","provider":"docker","arch":"x86_64","image":"litmusimage/amazonlinux:2023","runner":"ubuntu-22.04"},',
        '{"label":"RedHat-8","provider":"provision_service","arch":"x86_64","image":"rhel-8","runner":"ubuntu-latest"},',
        '{"label":"RedHat-9","provider":"provision_service","arch":"x86_64","image":"rhel-9","runner":"ubuntu-latest"},',
        '{"label":"RedHat-9-arm","provider":"provision_service","arch":"arm","image":"rhel-9-arm64","runner":"ubuntu-latest"},',
        '{"label":"Ubuntu-18.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:18.04","runner":"ubuntu-22.04"},',
        '{"label":"Ubuntu-22.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:22.04","runner":"ubuntu-latest"},',
        '{"label":"Ubuntu-22.04-arm","provider":"provision_service","arch":"arm","image":"ubuntu-2204-lts-arm64","runner":"ubuntu-latest"}',
        '],',
        '"collection":[',
        '"puppetcore8-nightly"',
        ']',
        '}'
      ].join
    end

    it 'run successfully' do
      expect(result.status_code).to eq 0
    end

    it 'generates the matrix' do
      expect(result.stdout).to include(
        '::warning::CentOS-6 no provisioner found',
        '::warning::Ubuntu-14.04 no provisioner found',
        '::group::matrix',
        '::group::spec_matrix'
      )
      expect(github_output_content).to include(matrix)
      expect(github_output_content).to include(
        'spec_matrix={"include":[{"puppet_version":"~> 8.0","ruby_version":3.2}]}'
      )
    end
  end

  context 'with --exclude-platforms "ubuntu-18.04"' do
    let(:result) { run_matrix_from_metadata_v3(['--puppetlabs', '--platform-exclude', 'ubuntu-18.04']) }
    let(:matrix) do
      [
        'matrix={',
        '"platforms":[',
        '{"label":"AmazonLinux-2","provider":"docker","arch":"x86_64","image":"litmusimage/amazonlinux:2","runner":"ubuntu-22.04"},',
        '{"label":"AmazonLinux-2023","provider":"docker","arch":"x86_64","image":"litmusimage/amazonlinux:2023","runner":"ubuntu-22.04"},',
        '{"label":"RedHat-8","provider":"provision_service","arch":"x86_64","image":"rhel-8","runner":"ubuntu-latest"},',
        '{"label":"RedHat-9","provider":"provision_service","arch":"x86_64","image":"rhel-9","runner":"ubuntu-latest"},',
        '{"label":"RedHat-9-arm","provider":"provision_service","arch":"arm","image":"rhel-9-arm64","runner":"ubuntu-latest"},',
        '{"label":"Ubuntu-22.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:22.04","runner":"ubuntu-latest"},',
        '{"label":"Ubuntu-22.04-arm","provider":"provision_service","arch":"arm","image":"ubuntu-2204-lts-arm64","runner":"ubuntu-latest"}',
        '],',
        '"collection":[',
        '"puppetcore8-nightly"',
        ']',
        '}'
      ].join
    end

    it 'run successfully' do
      expect(result.status_code).to eq 0
    end

    it 'generates the matrix without excluded platforms' do
      expect(result.stdout).to include(
        '::warning::CentOS-6 no provisioner found',
        '::warning::Ubuntu-14.04 no provisioner found',
        '::notice::platform-exclude filtered Ubuntu-18.04',
        '::group::matrix',
        '::group::spec_matrix'
      )
      expect(github_output_content).to include(matrix)
      expect(github_output_content).to include(
        'spec_matrix={"include":[{"puppet_version":"~> 8.0","ruby_version":3.2}]}'
      )
    end
  end

  context 'with --platform-exclude "ubuntu-(18.04|22.04)" --platform-exclude "redhat-[89]"' do
    let(:result) { run_matrix_from_metadata_v3(['--puppetlabs', '--platform-exclude', '(amazonlinux|ubuntu)-(2|18.04|22.04|2023)', '--platform-exclude', 'redhat-[89]']) }
    let(:matrix) do
      [
        'matrix={',
        '"platforms":[',
        '],',
        '"collection":[',
        '"puppetcore8-nightly"',
        ']',
        '}'
      ].join
    end

    it 'run successfully' do
      expect(result.status_code).to eq 0
    end

    it 'generates the matrix without excluded platforms' do
      expect(result.stdout).to include(
        '::warning::CentOS-6 no provisioner found',
        '::warning::Ubuntu-14.04 no provisioner found',
        '::notice::platform-exclude filtered RedHat-8',
        '::notice::platform-exclude filtered RedHat-9',
        '::notice::platform-exclude filtered Ubuntu-18.04',
        '::notice::platform-exclude filtered Ubuntu-22.04',
        '::group::matrix',
        '::group::spec_matrix'
      )
      expect(github_output_content).to include(matrix)
      expect(github_output_content).to include(
        'spec_matrix={"include":[{"puppet_version":"~> 8.0","ruby_version":3.2}]}'
      )
    end
  end

  context 'with --pe-include' do
    let(:result) { run_matrix_from_metadata_v3(['--puppetlabs', '--pe-include']) }
    let(:matrix) do
      [
        'matrix={',
        '"platforms":[',
        '{"label":"AmazonLinux-2","provider":"docker","arch":"x86_64","image":"litmusimage/amazonlinux:2","runner":"ubuntu-22.04"},',
        '{"label":"AmazonLinux-2023","provider":"docker","arch":"x86_64","image":"litmusimage/amazonlinux:2023","runner":"ubuntu-20.04"},',
        '{"label":"Ubuntu-18.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:18.04","runner":"ubuntu-22.04"},',
        '{"label":"Ubuntu-22.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:22.04","runner":"ubuntu-latest"}',
        '],',
        '"collection":[',
        '"puppetcore8-nightly"',
        ']',
        '}'
      ].join
    end

    it 'run successfully' do
      expect(result.status_code).to eq 0
    end

    it 'generates the matrix with PE LTS versions' do
      expect(result.stdout).to include(
        '::warning::CentOS-6 no provisioner found',
        '::warning::Ubuntu-14.04 no provisioner found',
        '::group::matrix',
        '::group::spec_matrix'
      )
      expect(github_output_content).to include(
        '"collection":["2023.8.4-puppet_enterprise","2021.7.9-puppet_enterprise","puppetcore8-nightly"'
      )
      expect(github_output_content).to include(
        'spec_matrix={"include":[{"puppet_version":"~> 8.0","ruby_version":3.2}]}'
      )
    end
  end
end
