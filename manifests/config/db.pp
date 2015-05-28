# == Class: gerrit::config::db
#
# This class pulls in the appropriate submodule for database management
# based upon the $options[database][type] attribute
#
# === Parameters
#
# This module does not accept any parameters
#
# === Variables
#
# The following variables are required
#
# [*db_tag*]
#   The tag to be used by exported database resource records so that a
#   collecting system may easily pick up the database resource
#
# [*manage_database*]
#   Should the database be managed. The default option of true means
#   that if a mysql or postgresql database are detected in the options
#   then resources will be exported via the
#   puppetlabs/{mysql,postgresql} module API. A db_tag (see above) needs
#   to be set as well so that a system picking up the resource can
#   acquire the appropriate exported resources
#
# [*options*]
#   A variable hash for configuration settings of Gerrit. The base class
#   will take the default options from gerrit::params and combine it
#   with anything in override_options (if defined) and use that as the
#   hash that is passed
#
# [*secure_option*]
#   A variable hash for secure configuration settings of of Gerrit. The
#   base class will take the default options from the gerrit::params and
#   combine it with anything in override_secure_options (if defined) and
#   use that as the has that is passed
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2014 Andrew Grimberg
#
class gerrit::config::db (
  $db_tag,
  $manage_database,
  $options,
  $secure_options
) {
  validate_string($db_tag)
  validate_bool($manage_database)
  validate_hash($options)
  validate_hash($secure_options)

  # Determine what database configuration to include
  # We only "manage" mysql and posgresql types and really only flags for
  # managing the DB are set
  if $options['database'] {
    case upcase($options['database']['type']) {
      'MYSQL':      {
                      class { '::gerrit::config::db::mysql':
                        db_tag          => $db_tag,
                        manage_database => $manage_database,
                        options         => $options,
                        secure_options  => $secure_options,
                      }
                    }
      'POSTGRESQL': {
                      class { '::gerrit::config::db::postgresql':
                        db_tag          => $db_tag,
                        manage_database => $manage_database,
                        options         => $options,
                        secure_options  => $secure_options,
                      }
                    }
      default:      { }
    }
  }
}
