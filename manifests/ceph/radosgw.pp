#
# Class rjil::ceph::radosgw
# Purpose: Configure ceph radosgw
#
# == Parameters
#

class rjil::ceph::radosgw {

  include ::ceph::radosgw

  ##
  # Validation tests
  ##
  include rjil::test::ceph_radosgw

  rjil::jiocloud::consul::service { 'radosgw':
    tags          => ['real'],
    port          => 80,
    check_command => '/usr/lib/nagios/plugins/check_http -H localhost',
  }

}
