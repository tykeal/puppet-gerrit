# == Define: gerrit::config::git_config
#
# This define is a helper function for setting config options in
# gerrit.conf and secure.config
#
# === Parameters
#
# This class accepts no parameters directly
#
# === Variables
#
# [*ensure*]
#   Ensure if the value is set or unset (defaults to present)
#
# [*config_file*]
#   The pariticular gerrit config file that is to be manipulated
#   defaults to gerrit.config, required
#
# [*section*]
#   The section of the config file to be manipulated, required
#
# [*variable*]
#   The variable that is to be set (or unset), required
#
# [*value*]
#   The value that the variable is to be set to (or unset from),
#   required
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2014 Andrew Grimberg
#
define gerrit::config::git_config (
  $config_file,
  $section,
  $variable,
  $value,
  $ensure       = 'present',
) {
  # input validation
  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure. Allowed values are 'present' \
and 'absent'.")

  validate_absolute_path($config_file)

  validate_string($section)
  validate_string($variable)
  validate_string($value)

  case $ensure {
    'present': {
                $command = "git config -f ${config_file} --add \
${section}.${variable} '${value}'"
                $onlyif = "[ `git config -f ${config_file} --get-all \
${section}.${variable} | grep -c '${value}'` == \"0\" ]"
                }
    'absent': {
                $command = "git config -f ${config_file} --unset \
${section}.${variable} '${value}'"
                $onlyif = "[ `git config -f ${config_file} --get-all \
${section}.${variable} | grep -c '${value}'` == \"1\" ]"
              }
    default: { }
  }

  exec { "${title}-${section}-${variable}-${value}":
    command => $command,
    onlyif  => $onlyif,
    path    => [ '/usr/bin', '/usr/sbin' ],
    notify  => Class['Gerrit::Service']
  }
}
