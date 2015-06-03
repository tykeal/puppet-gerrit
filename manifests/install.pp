# == Class: gerrit::install
#
# This class does the base installation of Gerrit any any required
# supporting applications. This class should not be called directly but
# only via Class['gerrit']
#
# === Parameters
#
# This class accepts no parameters directly
#
# === Variables
#
# The following variables are required
#
# [*download_location*]
#   Base location for downloading the Gerrit war from
#
# [*gerrit_home*]
#   The home directory for the gerrit user / installation path
#
# [*gerrit_version*]
#   The version of the Gerrit war that will be downloaded
#
# [*install_git*]
#   Should this module make sure that git is installed? (NOTE: a git
#   installation is required for Gerrit to be able to operate. If this
#   is enabled [the default] then a module named ::git will be included
#   puppetlabs/git is the expected module)
#
# [*install_gitweb*]
#   Should this module make sure that gitweb is installed? (NOTE: This
#   will use the system package manager to install gitweb but will do no
#   extra configuration as it will be expected to be managed via gerrit)
#
# [*install_java*]
#   Should this module make sure that a jre is installed? (NOTE: a jre
#   installation is required for Gerrit to operate. If this is enabled
#   [the default] then a module named ::java will be included
#   puppetlabs/java is the expected module)
#
# [*options*]
#   A variable hash for configuration settings of Gerrit. The base class
#   will take the default options from gerrit::params and combine it
#   with anything in override_options (if defined) and use that as the
#   hash that is passed to gerrit::install
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2014 Andrew Grimberg
#
class gerrit::install (
  $download_location,
  $gerrit_home,
  $gerrit_version,
  $install_git,
  $install_gitweb,
  $install_java,
  $options
) {
  # Revalidate our variables just to be safe
  validate_string($download_location)
  validate_absolute_path($gerrit_home)
  validate_string($gerrit_version)
  validate_bool($install_git)
  validate_bool($install_gitweb)
  validate_bool($install_java)
  validate_hash($options)

  # include the java class if we are to install java
  if ($install_java) {
    include '::java'
  }

  # include the git class if we are to install git
  if ($install_git) {
    include '::git'
  }

  # install gitweb if desired
  if ($install_gitweb) {
    package { 'gitweb':
      ensure => installed,
    }
  }

  # manage the user
  $gerrit_user = $options['container']['user']
  validate_string($gerrit_user)

  user { $gerrit_user:
    ensure     => present,
    comment    => 'Gerrit Service User',
    home       => $gerrit_home,
    managehome => true,
    shell      => '/bin/bash',
    system     => true,
  }

  # setup the installation directory structure and git storage
  $gitpath = $options['gerrit']['basePath']
  validate_absolute_path($gitpath)

  file { [
      "${gerrit_home}/bin",
      "${gerrit_home}/etc",
      "${gerrit_home}/lib",
      "${gerrit_home}/logs",
      "${gerrit_home}/plugins",
      "${gerrit_home}/tmp",
      $gitpath,
    ]:
    ensure  => directory,
    owner   => $gerrit_user,
    group   => $gerrit_user,
    require => User[$gerrit_user],
  }

  # download gerrit
  exec { "download gerrit ${gerrit_version}":
    cwd     => "${gerrit_home}/bin",
    path    => [ '/usr/bin', '/usr/sbin' ],
    command => "curl -s -O ${download_location}/gerrit-${gerrit_version}.war",
    creates => "${gerrit_home}/bin/gerrit-${gerrit_version}.war",
    user    => $gerrit_user,
    group   => $gerrit_user,
  }
}
