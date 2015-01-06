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
# This class accepts no variables directly
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2014 Andrew Grimberg
#
class gerrit::initialize {
  $options        = $gerrit::options
  $gerrit_home    = $gerrit::gerrit_home
  $gerrit_version = $gerrit::gerrit_version
  $gerrit_user    = $options['container']['user']

  exec { 'gerrit_initialize':
    cwd     => $gerrit_home,
    path    => [ '/usr/bin', '/usr/sbin' ],
    command => "java -jar ${gerrit_home}/bin/gerrit-${gerrit_version}.war \
init --batch && touch ${gerrit_home}/.gerrit_setup_complete.txt",
    creates => "${gerrit_home}/.gerrit_setup_complete.txt",
    user    => $gerrit_user,
  }
}
