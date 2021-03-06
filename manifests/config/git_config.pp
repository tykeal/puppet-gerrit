# == Define: gerrit::config::git_config
#
# This define is a helper function for setting config options in
# gerrit.conf and secure.config
#
# === Parameters
#
# This define accepts no parameters directly
#
# === Variables
#
# [*config_file*]
#   The pariticular gerrit config file that is to be manipulated
#   defaults to gerrit.config, required
#
# [*mode*]
#   The mode for the configuration file
#
# [*options*]
#   Hash used by the template for creating the resultant file the format
#   is as follows:
#
#   options = {
#     'section'     => {
#       'variable1' => 'Some variable',
#     },
#     'section.subsec' => {
#       'variable'     => [
#           'variable value',
#           'variable value2',
#       ],
#     },
#   }
#
# This will produce a config file similar to the following:
#
# [section]
#
# [section "subsec"]
#   variable = variable value
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
  $mode,
  $options      = {},
) {
  # input validation
  validate_absolute_path($config_file)
  validate_re($mode, '^[0-7]{4}$',
    "\"${mode}\" is not supported for mode. Allowed values are proper \
file modes.")
  validate_hash($options)

  $gerrit_group = $gerrit::config::gerrit_group
  $gerrit_user = $gerrit::config::gerrit_user

  file { $config_file:
    ensure  => file,
    owner   => $gerrit_user,
    group   => $gerrit_group,
    mode    => $mode,
    content => template('gerrit/git.ini.erb'),
  }
}
