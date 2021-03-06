define rjil::jiocloud::consul::service(
  $port,
  $check_command = "true",
  $interval      = '10s',
  $tags          = [],
) {
  $service_hash = {
    service => {
      name  => $name,
      port  => $port + 0,
      tags  => $tags,
      check => {
        script => $check_command,
        interval => $interval
      }
    }
  }

  ensure_resource( 'file', '/etc/consul',
    {'ensure' => 'directory'}
  )

  file { "/etc/consul/$name.json":
    ensure => "present",
    content => template('rjil/consul.service.erb'),
  } ~> Exec <| title == 'reload-consul' |>
}
