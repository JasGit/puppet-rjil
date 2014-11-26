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
  rjil::test { 'ceph_radosgw.sh': }

  rjil::jiocloud::consul::service { 'radosgw':
    tags          => ['real'],
    port          => 80,
    check_command => '/usr/lib/jiocloud/tests/ceph_radosgw.sh',
    require       => Rjil::Test['ceph_radosgw.sh'],
  }

}
