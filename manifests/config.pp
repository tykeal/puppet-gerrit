# == Class: gerrit::config
#
# This class does the basic configuration of Gerrit
#
# === Parameters
#
# This class accepts no parameters directly
#
# === Variables
#
# The following variables are required
#
# [*db_tag*]
#   The tag to be used by exported database resource records so that a
#   collecting system may easily pick up the database resource
#
# [*default_secure_options*]
#   The default_secure_options hash the base gerrit class should be
#   passing gerrit::params::default_secure_options
#
# [*extra_configs*]
#   A hash that is used to add additional configuration files to the
#   gerrit system. The hash is formatted as follows:
#
#   extra_configs   => {
#     config_name1  => {
#       config_file => 'fully_qualified_path_to_where_file_should_live',
#       mode        => '0660', # file mode the config should have
#       options     => {
#         # This hash is built the same way that the override*options hashes
#         # are built as it is handed to the same function
#       },
#     },
#     config_name2 => {
#       config_file => 'fully_qualified_path_to_where_file_should_live',
#       mode        => '0660', # file mode the config should have
#       options     => {
#         # This hash is built the same way that the override*options hashes
#         # are built as it is handed to the same function
#       },
#     },
#   }
#
#   This is most useful for adding needed configuration files needed by
#   plugins. For instance an example for the replication plugion could
#   be (assumption that the default gerrit home of /opt/gerrit is used)
#   See also the options passed to gerrit::config::git_config
#
#   extra_configs         => {
#     replication_conf    => {
#       config_file       => '/opt/gerrit/etc/replication.config',
#       mode              => '0644',
#       options           => {
#         'remote.github' => {
#           url           => 'git@github.com:example_com/${name}.git',
#           push          => [
#               '+refs/heads/*:refs/heads/*',
#               '+refs/tags/*:refs/tags/*'
#           ],
#           timeout         => '5',
#           threads         => '5',
#           authGroup       => 'Replicate Only What This Group Can See',
#           remoteNameStyle => 'dash',
#         },
#       }
#     },
#   }
#
# [*gerrit_home*]
#   The home directory for the gerrit user / installation path
#
# [*manage_database*]
#   Should the database be managed. The default option of true means
#   that if a mysql or postgresql database are detected in the options
#   then resources will be exported via the
#   puppetlabs/{mysql,postgresql} module API. A db_tag (see above) needs
#   to be set as well so that a system picking up the resource can
#   acquire the appropriate exported resources
#
# [*manage_firewall*]
#   Should the module insert firewall rules for the webUI and SSH?
#   (NOTE: this requires a module compatible with puppetlabs/firewall)
#
# [*options*]
#   A variable hash for configuration settings of Gerrit. The base class
#   will take the default options from gerrit::params and combine it
#   with anything in override_options (if defined) and use that as the
#   hash that is passed
#
# [*override_secure_options*]
#   The override_secure_options hash that should have been passed to the
#   base gerrit class
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2014 Andrew Grimberg
#
class gerrit::config (
  $db_tag,
  $default_secure_options,
  $extra_configs,
  $gerrit_group,
  $gerrit_home,
  $gerrit_user,
  $manage_database,
  $manage_firewall,
  $options,
  $override_secure_options
) {
  validate_string($db_tag)
  validate_hash($default_secure_options)
  validate_hash($extra_configs)
  validate_string($gerrit_group)
  validate_absolute_path($gerrit_home)
  validate_string($gerrit_user)
  validate_bool($manage_database)
  validate_bool($manage_firewall)
  validate_hash($options)
  validate_hash($override_secure_options)

  anchor { 'gerrit::config::begin': }
  anchor { 'gerrit::config::end': }

  # gerrit configuration
  ::gerrit::config::git_config { 'gerrit.config':
    config_file => "${gerrit_home}/etc/gerrit.config",
    mode        => '0660',
    options     => $options,
  }

  $real_secure_options = merge($default_secure_options,
    $override_secure_options)

  ::gerrit::config::git_config { 'secure.config':
    config_file => "${gerrit_home}/etc/secure.config",
    mode        => '0600',
    options     => $real_secure_options,
  }

  # create any extra configs
  create_resources(::gerrit::config::git_config, $extra_configs)

  class { '::gerrit::config::db':
    db_tag          => $db_tag,
    manage_database => $manage_database,
    options         => $options,
    secure_options  => $real_secure_options,
  }

  class { '::gerrit::config::firewall':
    manage_firewall => $manage_firewall,
    options         => $options,
  }

  Anchor['gerrit::config::begin'] ->
    Class['gerrit::config::db'] ->
  Anchor['gerrit::config::end']

  Anchor['gerrit::config::begin'] ->
    Class['gerrit::config::firewall'] ->
  Anchor['gerrit::config::end']
}
