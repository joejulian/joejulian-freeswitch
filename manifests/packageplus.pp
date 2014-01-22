define freeswitch::packageplus(
  $ensure = present
) {
  $deleted = delete("${name}", '@')
  if "@${deleted}" == "${name}" { # string started with @
    $valid_group = "${deleted}"
    $installed = "/usr/bin/yum grouplist '${valid_group}' | /bin/grep -q '^Installed Groups'"
    exec { "yum-groupinstall-${name}":
      command => $ensure ? {
        absent => "/usr/bin/yum -y groupremove '${valid_group}'",
        default => "/usr/bin/yum -y groupinstall '${valid_group}'",
      },
      logoutput => on_failure,
      unless  => $ensure ? {
        absent => undef,
        default => "${installed}",
      },
      onlyif  => $ensure ? {
        absent => "${installed}",
        default => undef,
      },
    }
  } elsif "${deleted}" == "${name}" { # no @ was present
    package { "${name}":
      ensure => $ensure,
    }
  } else {
    fail("The package or group name of '${name}' is invalid.")
  }
}


