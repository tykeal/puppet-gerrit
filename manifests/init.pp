# == Class: gerrit
#
# This class is the entry point into installing and configuring a Gerrit
# server
#
# === Parameters
#
# [*db_tag*]
#   The tag to be used by exported database resource records so that a
#   collecting system may easily pick up the database resource
#
# [*download_location*]
#   Base location for downloading the Gerrit war from
#
# [*extra_configs*]
#   A hash that is used to add additional configuration files to the
#   gerrit system. The hash is formatted as follows:
#
#   extra_configs               => {$
#     configID1                 => {$
#       config_file             => 'fully_qualified_file_name',$
#       mode                    => '0644',$
#       options                 => {$
#         'section1'            => {$
#           'option1'           => 'basic string option',$
#           'option2'           => [$
#             'option2 array entry 1',$
#             'option2 array entry 2'$
#           ],$
#         },$
#         'section2.subsection' => {$
#           'option3' => 'option 3 in [section2 "subsection"]'$
#         },$
#       },$
#     },$
#     configID2                 => {$
#       config_file             => 'another_fully_qualified_file_name',$
#       mode                    => '0644',$
#       options                 => {$
#         'section1'            => {$
#           'option1'           => 'one more option string',$
#         },$
#       }$
#     }$
#   }$
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
# [*gerrit_group*]
#   The primary group or gid of the gerrit user. Default is 'gerrit'
#
# [*gerrit_home*]
#   The home directory for the gerrit user / installation path
#
# [*gerrit_site_options*]
#   Override options for installation of the 3 Gerrit site files. The
#   format of this option hash is as follows:
#   gerrit_site_options       => {
#     'GerritSite.css'        => [valid_file_resource_source],
#     'GerritSiteHeader.html' => [valid_file_resource_source],
#     'GerritSiteFooter.html' => [valid_file_resource_source],
#   }
#
#   If an option is not present then the default "blank" file will be
#   used.
#
#   This hash is only used if manage_site_skin is true (default)
#
# [*gerrit_user*]
#   The user that Gerrit runs as. Default is 'gerrit'
#
# [*gerrit_version*]
#   The version of the Gerrit war that will be downloaded
#
# [*install_default_plugins*]
#   Should the default plugins be installed? If true (default) then use
#   the plugin_list array to specify which plugins specifically should
#   be installed.
#
# [*install_git*]
#   Should this module make sure that git is installed? (NOTE: a git
#   installation is required for Gerrit to be able to operate. If this
#   is enabled [the default] then a module named ::git will be included
#   puppetlabs/git is the expected module)
#
# [*install_gitweb*]
#   Should this module make sure that gitweb is installed? (NOTE: This
#   will use the system package manager to install gitweb but will do no
#   extra configuration as it will be expected to be managed via gerrit)
#
# [*install_java*]
#   Should this module make sure that a jre is installed? (NOTE: a jre
#   installation is required for Gerrit to operate. If this is enabled
#   [the default] then a module named ::java will be included
#   puppetlabs/java is the expected module)
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
# [*manage_site_skin*]
#   Should the Gerrit site theming be managed by the module. If true
#   passing an options hash to gerrit_site_options will override the
#   default "blank" skin files.
#
# [*manage_static_site*]
#   Should the ~gerrit/static structure be managed by the module.  If
#   true then static_source must be set.
#   default false
#
# [*manage_user*]
#   Should the creation of the Gerrit $user be managed by the module.
#   default true
#
# [*override_options*]
#   A variable hash for configuration settings of Gerrit. Please see
#   gerrit::params for the default_options hash
#
# [*override_secure_options*]
#   Similar to the override_options hash, this one is used for setting
#   the options in Gerrit's secure.config
#
# [*plugin_list*]
#   An array specifying the default plugins that should be installed.
#   The names are specified without the .jar
#   The current plugins auto-installed are all from gerrit v2.9.3
#
# [*refresh_service*]
#   Should the gerrit service be refreshed on modifications to either
#   the gerrit.config or secure.config?
#   default true
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
# [*static_source*]
#   A File resource source that will be recursively pushed if
#   manage_static_site is set to true. All files in the source will be
#   pushed to the ~gerrit/site
#
# [*third_party_plugins*]
#   A hash declaring all the third party plugins that are to be
#   installed and where to acquire them.
#
#   Default: {}
#
#   example:
#
#   third_party_plugins => {
#     'delete-project'  => {
#       plugin_source   =>
#       'https://gerrit-ci.gerritforge.com/view/Plugins-stable-2.11/job/plugin-delete-project-stable-2.11/lastSuccessfulBuild/artifact/buck-out/gen/plugins/delete-project/delete-project.jar',
#     }
#   }
#
# === Variables
#
# No variables are expressly required to be set, there should be sane
# defaults already configured in gerrit::params which can be overridden
# via hiera
#
# === Examples
#
#  include 'gerrit'
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2014 Andrew Grimberg
#
class gerrit (
  $db_tag                   = '',
  $download_location        = $gerrit::params::download_location,
  $extra_configs            = {},
  $gerrit_group             = $gerrit::params::gerrit_group,
  $gerrit_home              = $gerrit::params::gerrit_home,
  $gerrit_site_options      = {},
  $gerrit_user              = $gerrit::params::gerrit_user,
  $gerrit_version           = $gerrit::params::gerrit_version,
  $install_default_plugins  = $gerrit::params::install_default_plugins,
  $install_git              = $gerrit::params::install_git,
  $install_gitweb           = $gerrit::params::install_gitweb,
  $install_java             = $gerrit::params::install_java,
  $manage_database          = $gerrit::params::manage_database,
  $manage_firewall          = $gerrit::params::manage_firewall,
  $manage_site_skin         = $gerrit::params::manage_site_skin,
  $manage_static_site       = $gerrit::params::manage_static_site,
  $manage_user              = $gerrit::params::manage_user,
  $override_options         = {},
  $override_secure_options  = {},
  $plugin_list              = $gerrit::params::plugin_list,
  $refresh_service          = $gerrit::params::refresh_service,
  $service_enabled          = $gerrit::params::service_enabled,
  $static_source            = '',
  $third_party_plugins      = {}
) inherits gerrit::params {

  # Make sure that all of the params are properly formated
  validate_string($db_tag)
  validate_string($download_location)
  validate_hash($extra_configs)
  validate_string($gerrit_group)
  validate_absolute_path($gerrit_home)
  validate_hash($gerrit_site_options)
  validate_string($gerrit_user)
  validate_string($gerrit_version)
  validate_bool($install_default_plugins)
  validate_bool($install_git)
  validate_bool($install_gitweb)
  validate_bool($install_java)
  validate_bool($manage_database)
  validate_bool($manage_site_skin)
  validate_bool($manage_static_site)
  validate_bool($manage_user)
  validate_hash($override_options)
  validate_hash($override_secure_options)
  validate_array($plugin_list)
  validate_bool($refresh_service)
  validate_string($static_source)
  validate_hash($third_party_plugins)

  unless is_bool($service_enabled) {
    validate_re($service_enabled, '^manual$',
      "${service_enabled} is not supported for service_enabled. \
Allowed values are true, false, 'manual'.")
  }

  # Create a merged together set of options. Rightmost hashes win over left.
  $options = merge($gerrit::params::default_options, $override_options)

  $secure_options = merge($gerrit::params::default_secure_options,
    $override_secure_options)

  anchor { 'gerrit::begin': }
  anchor { 'gerrit::end': }

  class { '::gerrit::install':
    download_location       => $download_location,
    gerrit_group            => $gerrit_group,
    gerrit_home             => $gerrit_home,
    gerrit_site_options     => $gerrit_site_options,
    gerrit_user             => $gerrit_user,
    gerrit_version          => $gerrit_version,
    install_default_plugins => $install_default_plugins,
    install_java            => $install_java,
    install_git             => $install_git,
    install_gitweb          => $install_gitweb,
    manage_site_skin        => $manage_site_skin,
    manage_static_site      => $manage_static_site,
    manage_user             => $manage_user,
    options                 => $options,
    plugin_list             => $plugin_list,
    static_source           => $static_source,
    third_party_plugins     => $third_party_plugins,
  }

  class { '::gerrit::config':
    db_tag                  => $db_tag,
    default_secure_options  => $gerrit::params::default_secure_options,
    extra_configs           => $extra_configs,
    gerrit_group            => $gerrit_group,
    gerrit_home             => $gerrit_home,
    gerrit_user             => $gerrit_user,
    manage_database         => $manage_database,
    manage_firewall         => $manage_firewall,
    options                 => $options,
    override_secure_options => $override_secure_options,
  }

  class { '::gerrit::initialize':
    gerrit_group   => $gerrit_group,
    gerrit_home    => $gerrit_home,
    gerrit_user    => $gerrit_user,
    gerrit_version => $gerrit_version,
    options        => $options,
  }

  class { '::gerrit::service':
    service_enabled => $service_enabled,
  }

  Anchor['gerrit::begin'] ->
    Class['gerrit::install'] ->
    Class['gerrit::config'] ->
    Class['gerrit::initialize'] ->
    Class['gerrit::service'] ->
  Anchor['gerrit::end']

  if ($refresh_service) {
    # gerrit.config and secure.config should refresh service
    # We do this outside the classes because they don't have internal
    # dependencies on each other so can't test / compile properly
    Gerrit::Config::Git_config['gerrit.config'] ~> Class['gerrit::service']
    Gerrit::Config::Git_config['secure.config'] ~> Class['gerrit::service']
  }
}
