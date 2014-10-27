class setup_mongo (
 $use_syslog       = true,
 $verbose          = true,
 $internal_address = <internal_address>,
 $metering_secret  = '1234567890',
 $db_password      = 'ceilometer',
 $primary          = <primary>,
 $mongo_hosts      = [ <mongo_hosts> ],
) {
  if $primary {
    class { 'openstack::mongo_primary':
      mongodb_bind_address        => [ '127.0.0.1', $internal_address ],
      ceilometer_metering_secret  => $metering_secret,
      ceilometer_db_password      => $db_password,
      ceilometer_replset_members  => $mongo_hosts,
      use_syslog                  => $use_syslog,
      verbose                     => $verbose,
    }
  } else {
    class { 'openstack::mongo_secondary':
      mongodb_bind_address        => [ '127.0.0.1', $internal_address ],
      use_syslog                  => $use_syslog,
      verbose                     => $verbose,
    }
  }
}

include setup_mongo
