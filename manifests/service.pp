# == Class: gerrit::service
#
# This class manages the Gerrit service itself
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
class gerrit::service {

  if (is_bool($gerrit::service_enabled)) {
    # $gerrit::service_enabled maps directly to ensure
    $ensure = $gerrit::service_enabled
  }
  else {
    # $gerrit::service_enabled maps only to enable, set ensure to undef
    $ensure = undef
  }

  $enable = $gerrit::service_enabled

  service { 'gerrit':
    ensure     => $ensure,
    enable     => $enable,
    hasrestart => true,
    hasstatus  => true,
  }
}
