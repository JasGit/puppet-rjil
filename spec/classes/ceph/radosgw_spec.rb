require 'spec_helper'
require 'hiera-puppet-helper'

describe 'rjil::ceph::radosgw' do

  let :hiera_data do
    {
      'ceph::radosgw::keystone_url'                 => 'http://server:port/test',
      'ceph::radosgw::keystone_admin_token'         => 'token',
      'ceph::radosgw::mon_key'                      => 'mon-key',
      'radosgw_port'                                => '80',
      'openstack_extras::auth_file::admin_password' => 'pass',
    }
  end

  let :facts do
    {
      'lsbdistid'              => 'ubuntu',
      'lsbdistcodename'        => 'trusty',
      'osfamily'               => 'Debian',
      'interfaces'             => 'eth0,eth1',
      'ipaddress_eth0'         => '10.1.0.2',
      'concat_basedir'         => '/tmp/',
      'hostname'               => 'host1',
      'operatingsystemrelease' => '14.04',
    }
  end

  context 'with defaults' do
    it do
      should contain_class('rjil::test::ceph_radosgw')

      should contain_package('python-swiftclient')

      should contain_file('/usr/lib/jiocloud/tests/ceph_radosgw.sh')

      should contain_rjil__jiocloud__consul__service('radosgw').with({
        'tags'          => ['real'],
        'port'          => '80',
        'check_command' => '/usr/lib/nagios/plugins/check_http -H localhost',
      })

    end
  end
end
