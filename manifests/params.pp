# == Class: gerrit::params
#
# This class manages Gerrit parameters
#
# === Parameters
#
# [*user*]
#   The user that Gerrit runs as
# [*group*]
#   The group that Gerrit runs as
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2014 Andrew Grimberg, unless otherwise noted.
#
class gerrit::params {
  # authentication type
  $auth_type           = 'OpenID'
  $_allowed_auth_types = [
                            'OpenID',
                            'OpenID_SSO',
                            'HTTP',
                            'HTTP_LDAP',
                            'CLIENT_SSL_CERT_LDAP',
                            'LDAP',
                            'LDAP_BIND',
                            'DEVELOPMENT_BECOME_ANY_ACCOUNT'
                          ]

  # gerrit base information
  $user  = 'gerrit'
  $basepath = '/srv/gerrit'

  # default gerrit download information
  $gerrit_version    = '2.9.2'
  $download_location = 'https://gerrit-releases.storage.googleapis.com'

  # location information
  $gerrit_home    = '/opt/gerrit'

  # management flags
  $install_git        = true
  $install_java       = true
  $manage_site_skin   = true
  $service_enabled    = true

  $manage_database = true

  # database information
  $database_hostname          = undef
  $database_username          = 'gerrit'
  $database_password          = undef
  $database_name              = 'db/ReviewDB'
  $database_backend           = 'H2'
  $_allowed_database_backends = [
                                  'H2',
                                  'JDBC',
                                  'MYSQL',
                                  'POSTGRESQL'
                                ]

  # default options hash
  $default_options = {
    'auth'      => {
      'type'    => {
        'value' => $gerrit::params::auth_type,
      },
    },
    'container' => {
      'user'    => {
        'value' => $gerrit::params::user,
      },
    },
    'gerrit'     => {
      'basePath' => {
        'value'  => $gerrit::params::basepath,
      },
    },
  }
}
