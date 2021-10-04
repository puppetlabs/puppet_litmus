# frozen_string_literal: true

def no_config_hash
  { 'groups' =>
    [
      { 'name' => 'ssh_nodes',
        'targets' =>
      [{ 'uri' => 'test.delivery.puppetlabs.net',
         'facts' => { 'provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64' } }] },
      { 'name' => 'winrm_nodes', 'targets' => [] },
    ] }
end

def no_docker_hash
  { 'groups' =>
    [{ 'name' => 'ssh_nodes', 'targets' => [] },
     { 'name' => 'winrm_nodes', 'targets' => [] }] }
end

def config_hash
  { 'groups' =>
[{ 'name' => 'ssh_nodes',
   'targets' =>
 [{ 'uri' => 'test.delivery.puppetlabs.net',
    'config' => { 'transport' => 'ssh', 'ssh' => { 'user' => 'root', 'password' => 'Qu@lity!', 'host-key-check' => false } },
    'facts' => { 'provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64' },
    'vars' => { 'role' => 'agent' } }] },
 { 'name' => 'winrm_nodes', 'targets' => [] }] }
end

def no_feature_hash
  { 'groups' =>
[{ 'name' => 'ssh_nodes',
   'targets' =>
 [{ 'uri' => 'test.delivery.puppetlabs.net',
    'config' => { 'transport' => 'ssh', 'ssh' => { 'user' => 'root', 'password' => 'Qu@lity!', 'host-key-check' => false } },
    'facts' => { 'provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64' } }] },
 { 'name' => 'winrm_nodes', 'targets' => [] }] }
end

def feature_hash_group
  { 'groups' =>
[{ 'name' => 'ssh_nodes',
   'targets' =>
 [{ 'uri' => 'test.delivery.puppetlabs.net',
    'config' => { 'transport' => 'ssh', 'ssh' => { 'user' => 'root', 'password' => 'Qu@lity!', 'host-key-check' => false } },
    'facts' => { 'provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64' } }],
   'features' => ['puppet-agent'] },
 { 'name' => 'winrm_nodes', 'targets' => [] }] }
end

def empty_feature_hash_group
  { 'groups' =>
[{ 'name' => 'ssh_nodes',
   'targets' =>
 [{ 'uri' => 'test.delivery.puppetlabs.net',
    'config' => { 'transport' => 'ssh', 'ssh' => { 'user' => 'root', 'password' => 'Qu@lity!', 'host-key-check' => false } },
    'facts' => { 'provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64' } }],
   'features' => [] },
 { 'name' => 'winrm_nodes', 'targets' => [] }] }
end

def feature_hash_node
  { 'groups' =>
[{ 'name' => 'ssh_nodes',
   'targets' =>
 [{ 'uri' => 'test.delivery.puppetlabs.net',
    'config' => { 'transport' => 'ssh', 'ssh' => { 'user' => 'root', 'password' => 'Qu@lity!', 'host-key-check' => false } },
    'facts' => { 'provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64' },
    'features' => ['puppet-agent'] }] },
 { 'name' => 'winrm_nodes', 'targets' => [] }] }
end

def empty_feature_hash_node
  { 'groups' =>
[{ 'name' => 'ssh_nodes',
   'targets' =>
 [{ 'uri' => 'test.delivery.puppetlabs.net',
    'config' => { 'transport' => 'ssh', 'ssh' => { 'user' => 'root', 'password' => 'Qu@lity!', 'host-key-check' => false } },
    'facts' => { 'provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64' },
    'features' => [] }] },
 { 'name' => 'winrm_nodes', 'targets' => [] }] }
end

def foo_node
  { 'uri' => 'foo',
    'facts' => { 'provisioner' => 'bar', 'platform' => 'ubuntu' } }
end

def complex_inventory
  { 'groups' =>
    [
      {
        'name' => 'ssh_nodes',
        'groups' => [
          { 'name' => 'frontend',
            'targets' => [
              {
                'uri' => 'test.delivery.puppetlabs.net',
                'config' => { 'transport' => 'ssh', 'ssh' => { 'user' => 'root', 'password' => 'Qu@lity!', 'host-key-check' => false } },
                'facts' => { 'provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64' },
                'vars' => { 'role' => 'agent' },
              },
              {
                'uri' => 'test2.delivery.puppetlabs.net',
                'config' => { 'transport' => 'ssh', 'ssh' => { 'user' => 'root', 'password' => 'Qu@lity!', 'host-key-check' => false } },
                'facts' => { 'provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64' },
                'vars' => { 'role' => 'server' },
              },
              {
                'uri' => 'test3.delivery.puppetlabs.net',
                'config' => { 'transport' => 'ssh', 'ssh' => { 'user' => 'root', 'password' => 'Qu@lity!', 'host-key-check' => false } },
                'vars' => { 'roles' => %w[agent nginx webserver] },
              },
            ] },
        ],
      },
      {
        'name' => 'winrm_nodes',
        'targets' => [
          {
            'uri' => 'test4.delivery.puppetlabs.net',
            'config' => { 'transport' => 'winrm', 'winrm' => { 'user' => 'admin', 'password' => 'Qu@lity!' } },
            'facts' => { 'provisioner' => 'vmpooler', 'platform' => 'centos-5-x86_64' },
            'vars' => { 'roles' => %w[agent iis webserver] },
          },
        ],
      },
    ] }
end
