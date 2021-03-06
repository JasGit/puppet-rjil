require 'spec_helper'
require 'hiera-puppet-helper'

describe 'rjil::neutron' do
  let:facts do
    {
      :operatingsystem  => 'Debian',
      :osfamily         => 'Debian',
      :concat_basedir   => '/tmp',
      :hostname         => 'node1',
      :interfaces       => 'eth0,lo',
      :ipaddress_eth0   => '10.1.1.100',
      :lsbdistid        => 'ubuntu',
      :lsbdistcodename  => 'trusty',
    }
  end
  let :hiera_data do
    {
      'neutron::server::auth_host'                  => '10.1.1.10',
      'neutron::server::auth_password'              => 'pass',
      'openstack_extras::auth_file::admin_password' => 'pw',
      'contrail::keystone_host'                     => '10.1.1.1',
      'contrail::keystone_admin_token'              => 'token',
      'contrail::keystone_admin_password'           => 'pass',
      'contrail::keystone_auth_password'           => 'pass',
      'neutron::rabbit_password'                    => 'guest',
      'neutron::core_plugin'                        => 'coreplugin',
      'neutron::service_plugins'                    => ['serviceplugin1'],
      'neutron::quota::quota_driver'                => 'contraildriver',
      'rjil::neutron::api_extensions_path'          => 'extensionspath',
      'rjil::neutron::service_provider'             => 'serviceprovider',
      'rjil::neutron::public_cidr'                  => '1.1.1.0/24',
      'rjil::neutron::keystone_admin_password'      => 'pass',
    }
  end

  context 'with defaults' do
    it  do
      should contain_file('/usr/lib/jiocloud/tests/neutron.sh')
      should contain_file('/usr/lib/jiocloud/tests/floating_ip.sh')
      should contain_package('python-six').with_ensure('latest').that_comes_before('Class[neutron::server]')
      should contain_class('neutron')
      should contain_class('neutron::server')
      should contain_class('neutron::quota')
      should contain_neutron_config('DEFAULT/api_extensions_path').with_value('extensionspath')
      should contain_neutron_config('service_providers/service_provider').with_value('serviceprovider')
      should contain_neutron_network('public').with({
        'ensure'          => 'present',
        'router_external' => true
      })

      should contain_neutron_subnet('pub_subnet1').with({
        'ensure'       => 'present',
        'cidr'         => '1.1.1.0/24',
        'network_name' => 'public'
      })

      should contain_rjil__jiocloud__consul__service('neutron').with({
        'tags'      => ['real'],
        'port'      => 9696,
        'check_command' => "/usr/lib/nagios/plugins/check_http -I 127.0.0.1 -p 9696",
      })

      should contain_exec('empty_neutron_conf').with({
        'command'     => 'mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.bak_puppet',
        'refreshonly' => true,
        'subscribe'   => 'Package[neutron-server]',
      })

      should contain_contrail_rt('default-domain:services:public').with({
        'ensure'             => 'present',
        'rt_number'          => 10000,
        'router_asn'         => 64512,
        'api_server_address' => 'real.neutron.service.consul',
        'admin_password'     => 'pass',
        'require'            => 'Neutron_network[public]',
      })
    end
  end
end
