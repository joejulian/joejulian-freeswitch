# == Class: freeswitch
#
# Full description of class freeswitch here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { freeswitch:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class freeswitch::source (
  $freeswitch_version
){
  freeswitch::packageplus { [
    '@development',
    'expat-devel',
    'keyutils-libs-devel',
    'krb5-devel',
    'libcom_err-devel',
    'libcurl-devel',
    'libidn-devel',
    'libjpeg-turbo-devel',
    'libselinux-devel',
    'libsepol-devel',
    'ncurses-devel',
    'openssl-devel',
    'python-devel',
    'rpm-build',
    'zlib-devel',
  ]:
    ensure => installed,
    before => File['/opt/freeswitch/source'],
  }

  file { '/opt/freeswitch/source':
    ensure => directory,
    owner  => 'freeswitch',
    group  => 'freeswitch',
  }

  exec { 'gitCloneFreeswitch':
    command => '/usr/bin/git clone git://git.freeswitch.org/freeswitch.git',
    creates => '/opt/freeswitch/source/freeswitch',
    cwd     => '/opt/freeswitch/source',
    user    => 'freeswitch',
  }

  if $freeswitch_version != 'current' and $freeswitch_version != undef {
    exec { 'gitCheckoutVersion':
      command => "/usr/bin/git checkout $freeswitch_version",
      unless  => "/usr/bin/git log | /usr/bin/head -n1 | grep -q $freeswitch_version",
      cwd     => '/opt/freeswitch/source/freeswitch',
      user    => 'freeswitch',
    }
    Exec['gitCheckoutVersion'] ->
    Exec['bootstrapFreeswitchSource']
  } elsif $freeswitch_version == 'current' {
    # DON'T DO THIS!!!
    exec { 'makeFreeswitchCurrent':
      command => '/usr/bin/make current',
      cwd     => '/opt/freeswitch/source/freeswitch',
      user    => 'freeswitch',
    }
    Exec['configureFreeswitchSource'] ->
    Exec['makeFreeswitchCurrent']
  }

  exec { 'bootstrapFreeswitchSource':
    command => '/opt/freeswitch/source/freeswitch/bootstrap.sh',
    creates => '/opt/freeswitch/source/freeswitch/configure',
    cwd     => '/opt/freeswitch/source/freeswitch/',
    user    => 'freeswitch',
  }

  exec { 'configureFreeswitchSource':
    command => '/opt/freeswitch/source/freeswitch/configure --prefix=/opt/freeswitch --with-python',
    creates => '/opt/freeswitch/source/freeswitch/config.status',
    cwd     => '/opt/freeswitch/source/freeswitch/',
    user    => 'freeswitch',
  }

  exec { 'makeFreeswitch':
    command => '/usr/bin/make',
    creates => '/opt/freeswitch/source/freeswitch/freeswitch',
    cwd     => '/opt/freeswitch/source/freeswitch/',
    user    => 'freeswitch',
  }

  File['/opt/freeswitch/source']->
  Exec['gitCloneFreeswitch']->
  Exec['bootstrapFreeswitchSource']->
  Exec['configureFreeswitchSource']->
  Exec['makeFreeswitch']
}
