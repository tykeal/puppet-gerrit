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
# The following variables are all required
#
# [*service_enabled*]
#   Determines if the mode the service is configured for:
#     true: (default) service is ensured started and enabled for reboot
#     false: service is ensured stopped and disabled for reboot
#     manual: service is configured as a manual service, refreshes /
#     notifications will behave per normal when a service is configured
#     with enable => manual. The service is not specifically started or
#     stopped
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2014 Andrew Grimberg
#
class gerrit::service (
  $service_enabled
) {
  unless is_bool($service_enabled) {
    validate_re($service_enabled, '^manual$',
      "${service_enabled} is not supported for service_enabled. \
Allowed values are true, false, 'manual'.")
  }

  if (is_bool($service_enabled)) {
    # $service_enabled maps directly to ensure
    $ensure = $service_enabled
  }
  else {
    # $service_enabled maps only to enable, set ensure to undef
    $ensure = undef
  }

  $enable = $service_enabled

  service { 'gerrit':
    ensure     => $ensure,
    enable     => $enable,
    hasrestart => true,
    hasstatus  => true,
  }
}
