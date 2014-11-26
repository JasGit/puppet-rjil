Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin/","/usr/local/sbin/" ], logoutput => true }

node /etcd/ {
  include rjil::base
  if $::etcd_discovery_token {
    $discovery = true
  } else {
    $discovery = false
  }
  class { 'rjil::jiocloud::etcd':
    discovery       => $discovery,
    discovery_token => $::etcd_discovery_token
  }
}
##
# setup ceph configuration and osds on st nodes
# These nodes wait at least one stmon to be registered in consul.
##

node /^st\d+/ {
  include rjil::base
  include rjil::ceph
  include rjil::ceph::osd
  ensure_resource('rjil::service_blocker', 'stmon', {})
  Class['rjil::base'] -> Rjil::Service_blocker['stmon'] ->
  Class['rjil::ceph::osd']
}

##
# single leader that will be used to ensure that all mons form a single cluster.
#
# The only difference in stmon and stmonleader is that stmonleader is the node
# which starts first in the ceph cluster initialization. After that, both
# those roles will serve the same purpose.
# All ceph servers and clients (st, stmon, cp, oc nodes) except stmonleader will wait for at least
# one "stmon" service node in consul.
#
# The leader will register the service in consul with name "stmon" (or
# any other name if overridden in hiera).
#
##

node /^stmonleader1/ {
  include rjil::base
  include rjil::ceph
  include rjil::ceph::mon
  include rjil::ceph::osd
  include rjil::ceph::radosgw
  rjil::jiocloud::consul::service { 'stmonleader':
    port => 6789,
    check_command => '/usr/lib/jiocloud/tests/check_ceph_mon.sh'
  }
}

##
# setup ceph osd and mon configuration on ceph Mon nodes.
# All ceph mon nodes are registered in consul as service name "stmon" (or any
# other name if overridden)
#
# stmon nodes will wait at least one "stmon" service to be up in consul before
# initialize themselves
##

node /^stmon\d+/ {
  include rjil::base
  include rjil::ceph
  include rjil::ceph::mon
  include rjil::ceph::osd
  include rjil::ceph::radosgw
  ensure_resource('rjil::service_blocker', 'stmonleader', {})
  Class[rjil::base] -> Rjil::Service_blocker['stmonleader']
  Rjil::Service_blocker['stmonleader'] -> Class['rjil::ceph::mon::mon_config']
}

##
## Setup contrail nodes
##
node /^ct\d+/ {
  include rjil::base
  include rjil::redis
  include rjil::cassandra
  include rjil::rabbitmq
  include rjil::zookeeper
  include rjil::haproxy
  include rjil::haproxy::contrail
  include rjil::contrail::server
  include rjil::neutron
}


##
## oc is openstack controller node which will have all
## openstack controller applications
##

node /^oc\d+/ {
  include rjil::base
  include rjil::memcached
  include rjil::keystone
  include rjil::cinder
  include rjil::glance
  include rjil::openstack_zeromq
  include rjil::nova::controller
}

#
# this is a variation of the controller that has a database installed
#

node /^ocdb\d+/ {
  include rjil::base
  include rjil::memcached
  include rjil::db
  include rjil::keystone
  include rjil::cinder
  include rjil::glance
  include rjil::nova::controller
  include rjil::openstack_zeromq
  include openstack_extras::keystone_endpoints
  include rjil::keystone::test_user
  # ensure that we don't create keystone objects until
  # the service is operational
  ensure_resource('rjil::service_blocker', 'keystone-admin', {})
  Rjil::Service_blocker['keystone-admin'] -> Class['openstack_extras::keystone_endpoints']
  Rjil::Service_blocker['keystone-admin'] -> Class['rjil::keystone::test_user']
}

#
# A variation of the controller that also runs a load balancer
#

node /^oclb\d+/ {
  include rjil::base
  include rjil::memcached
  include rjil::db
  include rjil::keystone
  include rjil::cinder
  include rjil::glance
  include rjil::openstack_zeromq
  include openstack_extras::keystone_endpoints
  include rjil::keystone::test_user
  include rjil::haproxy
  include rjil::haproxy::openstack
}

##
# compute nodes
# gcp is a special cp node which is also used as gateway for floating IP access
# in virtual cloud and vagrant environments. This is not being used in physical
# environments (staging and production)
# NOTE: There must be only one gcp node supported at this point of time.
##
node /^(cp|gcp)\d+/ {
  include rjil::base
  include rjil::ceph
  include rjil::contrail::vrouter
  include rjil::openstack_zeromq
  include rjil::nova::compute
}

node /^haproxy\d+/ {
  include rjil::base
  include rjil::haproxy
  include rjil::haproxy::openstack
}

node /^uc\d+/ {
  include rjil::base
  include rjil::jiocloud::undercloud
  include rjil::jiocloud::aptmirror
  include rjil::jiocloud::jenkins::master
  include rjil::jiocloud::aptrepo
  include rjil::jiocloud::gitolite
}
