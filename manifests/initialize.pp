# == Class: gerrit::initialize
#
# This class performs the actual gerrit initialization. It should be
# idempotent and only run once. We don't perform upgrades!
#
# === Parameters
#
# This class accepts no parameters directly
#
# === Variables
#
# The following variables are required
#
# [*gerrit_group*]
#   The primary group of the gerrit user
#
# [*gerrit_home*]
#   The home directory for the gerrit user / installation path
#
# [*gerrit_user*]
#   The user that gerrit runs as
#
# [*gerrit_version*]
#   The version of the Gerrit war that will be downloaded
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
class gerrit::initialize (
  $gerrit_group,
  $gerrit_home,
  $gerrit_user,
  $gerrit_version,
  $options
) {
  validate_string($gerrit_group)
  validate_string($gerrit_home)
  validate_string($gerrit_user)
  validate_string($gerrit_version)
  validate_hash($options)

  $gerrit_basepath  = $options['gerrit']['basePath']
  validate_absolute_path($gerrit_basepath)

  exec { 'gerrit_initialize':
    cwd     => $gerrit_home,
    path    => [ '/usr/bin', '/usr/sbin' ],
    command => "java -jar ${gerrit_home}/bin/gerrit-${gerrit_version}.war \
init -d ${gerrit_home} --batch && java -jar \
${gerrit_home}/bin/gerrit.war reindex -d ${gerrit_home}",
    creates => "${gerrit_basepath}/All-Projects.git/HEAD",
    group   => $gerrit_group,
    user    => $gerrit_user,
  }
}
