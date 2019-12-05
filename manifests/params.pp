# == Class: gerrit::params
#
# This class manages Gerrit parameters
#
# === Parameters
#
# [*auth_type*]
#   The authentication type that gerrit should use. Default OpenID. See
#   the Gerrit documentation for valid types
#
# [*basepath*]
#   The base location where Gerrit will store the git repositories
#
# [*gerrit_group*]
#   The primary group or gid of the Gerrit user
#
# [*gerrit_user*]
#   The user that Gerrit runs as
#
# [*gerrit_version*]
#   The version of Gerrit to download
#
# [*gitweb_package_name*]
#   The name of the package to use for gitweb installation
#
#   Type: string
#   Default: gitweb
#
# [*download_location*]
#   Where to download the gerrit war file from
#
# [*install_default_plugins*]
#   Should the default plugins be installed? If true (default) then use
#   the plugin_list array to specify which plugins specifically should
#   be installed.
#
# [*install_git*]
#   Should git be installed? (NOTE: A git installation is required for
#   Gerrit to operate. If true [the default] then ::git will be included
#   during the install phase. The expected puppet module is
#   puppetlabs/git)
#
# [*install_gitweb*]
#   Should gitweb be installed? This defaults to true.
#
# [*install_java*]
#   Should java be installed? (NOTE: java >= 1.7 is required for Gerrit
#   to operate. This flag which defaults to true indicates if the module
#   will do an include of ::java. The expected puppet module is the
#   puppetlabs/java module)
#
# [*manage_database*]
#   Should databases be managed? If set to true (the default) than if
#   MySQL or PostgreSQL are detected resources will be exported as
#   appropriate.
#
# [*manage_firewall*]
#   Should firewall rules be managed? If set to true (the default) then
#   firewall rules for the Gerrit webUI and SSH will be added via the
#   puppetlabs/firewall syntax
#
# [*manage_site_skin*]
#   Should we push Gerrit site skinning files to the system. If set to
#   true (the default) then the gerrit_site_options hash passed to the
#   base class definition will define where to find the proper files. If
#   no files are defined via the has then default "blank" files will be
#   pushed so that Gerrit does not need to be restarted should you later
#   decide to add skins.
#
# [*manage_static_site*]
#   Should we manage the contents of ${gerrit_home}/static?
#
# [*manage_user*]
#   Should we manage the creation of the Gerrit user?
#
# [*refresh_service*]
#   Should the gerrit service be refreshed on changes to gerrit.config
#   or secure.config?
#
# [*service_enabled*]
#   Should the Gerrit service be enabled? If true (the default) then the
#   service will be configured to start during boot as force started.
#
#   Valid options are:
#     true: the default - configure the service to start on boot and
#     force start the service on puppet runs
#
#     false: service is ensured stopped and disabled for reboot
#
#     manual: service is configured as a manual service, refreshes /
#     notifications will behave per normal when the service is
#     configured with enable => manual. The service is not specifically
#     started or stopped during system boot.
#
# [*default_options*]
#   The default options for a Gerrit system. It is expected that the
#   class will be handed a override_options hash which expands or
#   completely replaces the defaults defined here
#
# [*default_secure_options*]
#   The default secure options for a Gerrit system. It is expected that
#   the class will be handed a override_secure_options. The
#   auth.registerEmailPrivateKey and auth.restTokenPrivateKey options
#   are required. If set to 'GENERATE' (the default) then a system
#   idempotent system locked "random" string will be generated. It is
#   recommended that these values be overriden with custom strings, but
#   for ease of setup this system was developed.
#
# [*plugin_list*]
#   An array specifying the default plugins that should be installed.
#   The names are specified without the .jar
#   The current plugins auto-installed are all from gerrit v2.9.3
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

  # gerrit base information
  $gerrit_user        = 'gerrit'
  $gerrit_group       = 'gerrit'
  $basepath           = '/srv/gerrit'

  # default gerrit download information
  $gerrit_version     = '2.9.3'
  $download_location  = 'https://gerrit-releases.storage.googleapis.com'

  # default gitweb package
  $gitweb_package_name = 'gitweb'

  # location information
  $gerrit_home        = '/opt/gerrit'
  $java_home          = '/usr/lib/jvm/jre'

  # management flags
  $install_default_plugins = true
  $install_git             = true
  $install_gitweb          = true
  $install_java            = true
  $manage_database         = true
  $manage_firewall         = true
  $manage_site_skin        = true
  $manage_static_site      = false
  $manage_user             = true
  $refresh_service         = true
  $service_enabled         = true

  # default options hash
  $default_options = {
    'auth'      => {
      'type'    => $gerrit::params::auth_type,
    },
    'container'  => {
      'javaHome' => $gerrit::params::java_home,
      'user'     => $gerrit::params::gerrit_user,
    },
    'gerrit'     => {
      'basePath' => $gerrit::params::basepath,
      # According to the developers this just needs to be a unique string and
      # anything can be used. This is a bit easier than some GENERATE
      # functionality like is needed for the keys below
      'serverId' => "${::ipaddress}-${::fqdn}",
    },
    'index'  => {
      'type' => 'LUCENE',
    },
  }

  # default secure options hash
  $default_secure_options = {
    'auth'                      => {
      'registerEmailPrivateKey' => 'GENERATE',
      'restTokenPrivateKey'     => 'GENERATE',
    },
  }

  # default plugin list (this is for gerrit 2.9.3)
  $plugin_list = [
    'commit-message-length-validator',
    'download-commands',
    'replication',
    'reviewnotes'
  ]
}
