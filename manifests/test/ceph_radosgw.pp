#
# Class: rjil::test::ceph_radosgw
#   Adding tests for nova services
#

class rjil::test::ceph_radosgw {

  include openstack_extras::auth_file

  ensure_resource('package','python-swiftclient',{})

  rjil::test { 'ceph_radosgw.sh': }

}
