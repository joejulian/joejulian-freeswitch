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
class freeswitch (
  $freeswitch_version = undef
){
  freeswitch::packageplus { 'ghostscript': }

  file { '/opt/freeswitch':
    ensure => directory,
    owner  => 'freeswitch',
    group  => 'freeswitch',
  }

  file { '/usr/local/freeswitch':
    ensure => '/opt/freeswitch',
  }

  group { 'freeswitch':
    ensure     => present,
    forcelocal => true,
    gid        => 101,
    system     => true,
  }

  user { 'freeswitch':
    ensure     => present,
    comment    => 'Freeswitch User',
    forcelocal => true,
    gid        => 'freeswitch',
    home       => '/opt/freeswitch',
    system     => true,
    uid        => 101,
  }

  class { 'freeswitch::source': 
    freeswitch_version => $freeswitch_version 
  }

  exec { 'installFreeswitch':
    command => '/usr/bin/make install',
    creates => '/opt/freeswitch/bin/freeswitch',
    cwd     => '/opt/freeswitch/source/freeswitch/',
    user    => 'freeswitch',
  }

  file { '/etc/init.d/freeswitch':
    source => 'puppet://puppet/modules/freeswitch/freeswitch.init',
    ensure => present,
    mode   => 0744,
    owner  => 'root',
    group  => 'root',
  }

  service { 'freeswitch':
    ensure => running,
    enable => true,
  }

  Group['freeswitch']->
  User['freeswitch']->
  File['/opt/freeswitch'] ->
  File['/usr/local/freeswitch'] ->
  Class['freeswitch::source'] ->
  Exec['installFreeswitch']->
  File['/etc/init.d/freeswitch']->
  Service['freeswitch']
}
