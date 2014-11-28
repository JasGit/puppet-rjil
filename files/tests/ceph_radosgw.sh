#!/bin/bash
set -e
function fail {
  echo "CRITICAL: $@"
  exit 2
}

/usr/lib/nagios/plugins/check_http -H localhost || fail 'radosgw is not up'

source /root/openrc || fail 'Cannot source /root/openrc'

# Swift checks ##

# create container
swift post tc1 || fail 'Cannot create container'

# upload an object
pushd /root
swift upload tc1 openrc || fail 'Cannot upload object'

# Download the object
pushd /tmp
swift download tc1 openrc || fail 'Cannot download the object'

# Delete the object
swift delete tc1 openrc || fail 'Cannot delete the object'

# Delete the container
swift delete tc1 || fail 'Cannot delete the container'
