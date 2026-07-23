# frozen_string_literal: true

require 'spec_helper'
require 'json'

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
        '"puppetcore8","puppetcore9"',
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
      expect(github_output_content).to include('spec_matrix={"include":[{"puppet_version":"~> 8.0","ruby_version":3.2},{"puppet_version":"~> 9.0","ruby_version":4.0}]}')
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
        '{"label":"RedHat-10","provider":"provision_service","arch":"x86_64","image":"rhel-10","runner":"ubuntu-latest"},',
        '{"label":"RedHat-10-arm","provider":"provision_service","arch":"arm","image":"rhel-10-arm64","runner":"ubuntu-latest"},',
        '{"label":"Ubuntu-18.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:18.04","runner":"ubuntu-22.04"},',
        '{"label":"Ubuntu-22.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:22.04","runner":"ubuntu-latest"},',
        '{"label":"Ubuntu-22.04-arm","provider":"provision_service","arch":"arm","image":"ubuntu-2204-lts-arm64","runner":"ubuntu-latest"}',
        '],',
        '"collection":[',
        '"puppetcore8","puppetcore9"',
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
        'spec_matrix={"include":[{"puppet_version":"~> 8.0","ruby_version":3.2},{"puppet_version":"~> 9.0","ruby_version":4.0}]}'
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
        '{"label":"RedHat-10","provider":"provision_service","arch":"x86_64","image":"rhel-10","runner":"ubuntu-latest"},',
        '{"label":"RedHat-10-arm","provider":"provision_service","arch":"arm","image":"rhel-10-arm64","runner":"ubuntu-latest"},',
        '{"label":"Ubuntu-18.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:18.04","runner":"ubuntu-22.04"},',
        '{"label":"Ubuntu-22.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:22.04","runner":"ubuntu-latest"},',
        '{"label":"Ubuntu-22.04-arm","provider":"provision_service","arch":"arm","image":"ubuntu-2204-lts-arm64","runner":"ubuntu-latest"}',
        '],',
        '"collection":[',
        '"puppetcore8","puppetcore9"',
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
        'spec_matrix={"include":[{"puppet_version":"~> 8.0","ruby_version":3.2},{"puppet_version":"~> 9.0","ruby_version":4.0}]}'
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
        '{"label":"RedHat-10","provider":"provision_service","arch":"x86_64","image":"rhel-10","runner":"ubuntu-latest"},',
        '{"label":"RedHat-10-arm","provider":"provision_service","arch":"arm","image":"rhel-10-arm64","runner":"ubuntu-latest"},',
        '{"label":"Ubuntu-22.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:22.04","runner":"ubuntu-latest"},',
        '{"label":"Ubuntu-22.04-arm","provider":"provision_service","arch":"arm","image":"ubuntu-2204-lts-arm64","runner":"ubuntu-latest"}',
        '],',
        '"collection":[',
        '"puppetcore8","puppetcore9"',
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
        'spec_matrix={"include":[{"puppet_version":"~> 8.0","ruby_version":3.2},{"puppet_version":"~> 9.0","ruby_version":4.0}]}'
      )
    end
  end

  context 'with --platform-exclude "ubuntu-(18.04|22.04)" --platform-exclude "redhat-(8|9|10)"' do
    let(:result) { run_matrix_from_metadata_v3(['--puppetlabs', '--platform-exclude', '(amazonlinux|ubuntu)-(2|18.04|22.04|2023)', '--platform-exclude', 'redhat-(8|9|10)']) }
    let(:matrix) do
      [
        'matrix={',
        '"platforms":[',
        '],',
        '"collection":[',
        '"puppetcore8","puppetcore9"',
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
        '::notice::platform-exclude filtered RedHat-10',
        '::notice::platform-exclude filtered Ubuntu-18.04',
        '::notice::platform-exclude filtered Ubuntu-22.04',
        '::group::matrix',
        '::group::spec_matrix'
      )
      expect(github_output_content).to include(matrix)
      expect(github_output_content).to include(
        'spec_matrix={"include":[{"puppet_version":"~> 8.0","ruby_version":3.2},{"puppet_version":"~> 9.0","ruby_version":4.0}]}'
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
        '"puppetcore8"',
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
      expect(github_output_content).to match(/"collection":\[(?:"\d{4}\.\d+\.\d+-puppet_enterprise",)+"puppetcore8","puppetcore9"/)
      expect(github_output_content).to include(
        'spec_matrix={"include":[{"puppet_version":"~> 8.0","ruby_version":3.2},{"puppet_version":"~> 9.0","ruby_version":4.0}]}'
      )
    end
  end

  context 'with argument --nightly' do
    let(:result) { run_matrix_from_metadata_v3(['--puppetlabs', '--nightly'], env: { 'PUPPET_FORGE_TOKEN' => 'fake_token' }) }
    let(:matrix) do
      [
        'matrix={',
        '"platforms":[',
        '{"label":"AmazonLinux-2","provider":"docker","arch":"x86_64","image":"litmusimage/amazonlinux:2","runner":"ubuntu-22.04"},',
        '{"label":"AmazonLinux-2023","provider":"docker","arch":"x86_64","image":"litmusimage/amazonlinux:2023","runner":"ubuntu-22.04"},',
        '{"label":"RedHat-8","provider":"provision_service","arch":"x86_64","image":"rhel-8","runner":"ubuntu-latest"},',
        '{"label":"RedHat-9","provider":"provision_service","arch":"x86_64","image":"rhel-9","runner":"ubuntu-latest"},',
        '{"label":"RedHat-9-arm","provider":"provision_service","arch":"arm","image":"rhel-9-arm64","runner":"ubuntu-latest"},',
        '{"label":"RedHat-10","provider":"provision_service","arch":"x86_64","image":"rhel-10","runner":"ubuntu-latest"},',
        '{"label":"RedHat-10-arm","provider":"provision_service","arch":"arm","image":"rhel-10-arm64","runner":"ubuntu-latest"},',
        '{"label":"Ubuntu-18.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:18.04","runner":"ubuntu-22.04"},',
        '{"label":"Ubuntu-22.04","provider":"docker","arch":"x86_64","image":"litmusimage/ubuntu:22.04","runner":"ubuntu-latest"},',
        '{"label":"Ubuntu-22.04-arm","provider":"provision_service","arch":"arm","image":"ubuntu-2204-lts-arm64","runner":"ubuntu-latest"}',
        '],',
        '"collection":[',
        '"puppetcore8-nightly","puppetcore9-nightly"',
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
        'spec_matrix={"include":[{"puppet_version":"~> 8.0","ruby_version":3.2},{"puppet_version":"~> 9.0","ruby_version":4.0}]}'
      )
    end
  end

  context 'with --nightly and no PUPPET_FORGE_TOKEN' do
    let(:result) { run_matrix_from_metadata_v3(['--nightly'], env: { 'PUPPET_FORGE_TOKEN' => nil }) }

    it 'run successfully' do
      expect(result.status_code).to eq 0
    end

    it 'falls back to public puppet collection with a warning' do
      expect(result.stdout).to include('--nightly ignored: PUPPET_FORGE_TOKEN is not set, falling back to public puppet collection')
      expect(github_output_content).to include('"collection":["puppet8"]')
    end
  end

  context 'without PUPPET_FORGE_TOKEN' do
    let(:result) { run_matrix_from_metadata_v3(['--puppetlabs'], env: { 'PUPPET_FORGE_TOKEN' => nil }) }

    it 'run successfully' do
      expect(result.status_code).to eq 0
    end

    it 'falls back to public puppet collection' do
      result
      expect(github_output_content).to include('"collection":["puppet8"]')
    end
  end

  context 'with argument --latest-agent' do
    let(:result) { run_matrix_from_metadata_v3(['--puppetlabs', '--latest-agent']) }

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
      expect(github_output_content).to match(/{"collection":"puppetcore8","version":"\d+\.\d+\.\d+"}/)
      expect(github_output_content).to match(/{"collection":"puppetcore9","version":("\d+\.\d+\.\d+"|null)}/)
      expect(github_output_content).to include(
        'spec_matrix={"include":[{"puppet_version":"~> 8.0","ruby_version":3.2},{"puppet_version":"~> 9.0","ruby_version":4.0}]}'
      )
    end
  end

  context 'with --collection-platform-exclude' do
    let(:result) do
      run_matrix_from_metadata_v3(
        ['--collection-platform-exclude', '9:ubuntu-18.04'],
        env: { 'PUPPET_FORGE_TOKEN' => 'fake' }
      )
    end

    it 'runs successfully' do
      expect(result.status_code).to eq 0
    end

    it 'emits a matrix exclude for only the matching platform x collection' do
      result
      matrix = JSON.parse(github_output_content[/^matrix=(.+)$/, 1])
      expect(matrix['exclude']).to contain_exactly(
        'platforms' => {
          'label' => 'Ubuntu-18.04', 'provider' => 'docker', 'arch' => 'x86_64',
          'image' => 'litmusimage/ubuntu:18.04', 'runner' => 'ubuntu-22.04'
        },
        'collection' => 'puppetcore9'
      )
    end

    it 'keeps the platform and the collection usable in other combinations' do
      # Ubuntu-18.04 is still a platform and puppetcore9 is still a collection;
      # only the single pair is excluded (so Ubuntu-18.04 still runs on puppetcore8).
      result
      expect(github_output_content).to include('{"label":"Ubuntu-18.04","provider":"docker",')
      expect(github_output_content).to include('"collection":["puppetcore8","puppetcore9"]')
    end

    it 'logs the exclusion' do
      expect(result.stdout).to include('::notice::collection-platform-exclude filtered Ubuntu-18.04 x puppetcore9')
    end
  end

  context 'with an invalid --collection-platform-exclude spec' do
    let(:result) do
      run_matrix_from_metadata_v3(['--collection-platform-exclude', 'ubuntu-18.04'])
    end

    it 'fails with a helpful error' do
      expect(result.status_code).not_to eq 0
      expect(result.stdout).to include("--collection-platform-exclude 'ubuntu-18.04' must be MAJOR:PLATFORM_REGEX")
    end
  end
end
