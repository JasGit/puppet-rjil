# Define a radosgw
#
class rjil::keystone::radosgw (
  $region            = 'RegionOne',
  $public_protocol   = 'http',
  $public_address    = '127.0.0.1',
  $public_port       = undef,
  $admin_protocol    = undef,
  $admin_address     = undef,
  $internal_protocol = undef,
  $internal_address  = undef,
  $auth_name         = 'swift',
  $port              = 80,
) {

  if ! $public_port {
    $real_public_port = $port
  } else {
    $real_public_port = $public_port
  }

  if ! $admin_protocol {
    $real_admin_protocol = $public_protocol
  } else {
    $real_admin_protocol = $admin_protocol
  }

  if ! $internal_protocol {
    $real_internal_protocol = $public_protocol
  } else {
    $real_internal_protocol = $internal_protocol
  }

  if ! $admin_address {
    $real_admin_address = $public_address
  } else {
    $real_admin_address = $admin_address
  }
  if ! $internal_address {
    $real_internal_address = $public_address
  } else {
    $real_internal_address = $internal_address
  }

  keystone_service { $auth_name:
    ensure      => present,
    type        => 'object-store',
    description => 'Openstack Object-Store Service',
  }

  keystone_endpoint { "${region}/${auth_name}":
    ensure       => present,
    public_url   => "${public_protocol}://${public_address}:${real_public_port}/swift/v1",
    admin_url    => "${real_admin_protocol}://${real_admin_address}:${real_public_port}/swift/v1",
    internal_url => "${real_internal_protocol}://${real_internal_address}:${real_public_port}/swift/v1",
  }

}
