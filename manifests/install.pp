# == Class: gerrit::install
#
# This class does the base installation of Gerrit any any required
# supporting applications. This class should not be called directly but
# only via Class['gerrit']
#
# === Parameters
#
# This class accepts no parameters directly
#
# === Variables
#
# The following variables are required
#
# [*download_location*]
#   Base location for downloading the Gerrit war from
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
# [*plugin_list*]
#   An array specifying the default plugins that should be installed.
#   The names are specified without the .jar
#   The current plugins auto-installed are all from gerrit v2.9.3
#
# [*options*]
#   A variable hash for configuration settings of Gerrit. The base class
#   will take the default options from gerrit::params and combine it
#   with anything in override_options (if defined) and use that as the
#   hash that is passed to gerrit::install
#
# [*static_source*]
#   A File resource source that will be recursively pushed if
#   manage_static_site is set to true. All files in the source will be
#   pushed to the ~gerrit/site
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2014 Andrew Grimberg
#
class gerrit::install (
  $download_location,
  $gerrit_home,
  $gerrit_site_options,
  $gerrit_version,
  $install_default_plugins,
  $install_git,
  $install_gitweb,
  $manage_site_skin,
  $manage_static_site,
  $install_java,
  $options,
  $plugin_list,
  $static_source
) {
  # Revalidate our variables just to be safe
  validate_string($download_location)
  validate_absolute_path($gerrit_home)
  validate_hash($gerrit_site_options)
  validate_string($gerrit_version)
  validate_bool($install_default_plugins)
  validate_bool($install_git)
  validate_bool($install_gitweb)
  validate_bool($install_java)
  validate_bool($manage_site_skin)
  validate_bool($manage_static_site)
  validate_array($plugin_list)
  validate_hash($options)

  # include the java class if we are to install java
  if ($install_java) {
    include '::java'
  }

  # include the git class if we are to install git
  if ($install_git) {
    include '::git'
  }

  # install gitweb if desired
  if ($install_gitweb) {
    package { 'gitweb':
      ensure => installed,
    }
  }

  # manage the user
  $gerrit_user = $options['container']['user']
  validate_string($gerrit_user)

  user { $gerrit_user:
    ensure     => present,
    comment    => 'Gerrit Service User',
    home       => $gerrit_home,
    managehome => true,
    shell      => '/bin/bash',
    system     => true,
  }

  # service script installation
  case $::osfamily {
    'RedHat': {
      case $::operatingsystem {
        'Fedora': {
          if versioncmp($::operatingsystemrelease, '14') >= 0 {
            $use_systemd = true
          } else {
            $use_systemd = false
          }
        }
        # Default to EL systems
        default: {
          if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
            $use_systemd = true
          } else {
            $use_systemd = false
          }
        }
      }
    }
    # We don't currently support not RH based systems
    default: {
      fail("${::osfamily} is not presently supported")
    }
  }

  if ($use_systemd) {
    # Previous versions of this module always used the shipped script
    # this was a bad thing as puppet on systemd systems has issues
    # knowing if a service was actually enabled for start on boot so
    # we're going to make sure the old script is gone
    file { 'gerrit_init_script':
      ensure => absent,
      path   => '/etc/init.d/gerrit',
    }

    file { 'gerrit_systemd_script':
      ensure  => file,
      path    => '/usr/lib/systemd/system/gerrit.service',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("${module_name}/gerrit.service.erb"),
    }
  } else {
    # link to the init script that ships with gerrit
    file { 'gerrit_init_script':
      ensure => link,
      path   => '/etc/init.d/gerrit',
      target => "${gerrit_home}/bin/gerrit.sh",
    }
  }

  # install gerrit site skin bits
  if ($manage_site_skin) {
    ## GerritSite.css
    if has_key($gerrit_site_options, 'GerritSite.css') {
      validate_string($gerrit_site_options['GerritSite.css'])
      $gerrit_css = $gerrit_site_options['GerritSite.css']
    }
    else {
      $gerrit_css = 'puppet:///modules/gerrit/skin/GerritSite.css'
    }

    file { "${gerrit_home}/etc/GerritSite.css":
      owner   => $gerrit_user,
      group   => $gerrit_user,
      source  => $gerrit_css,
      require => User[$gerrit_user],
    }

    ## GerritSiteHeader.html
    if has_key($gerrit_site_options, 'GerritSiteHeader.html') {
      validate_string($gerrit_site_options['GerritSiteHeader.html'])
      $gerrit_header = $gerrit_site_options['GerritSiteHeader.html']
    }
    else {
      $gerrit_header = 'puppet:///modules/gerrit/skin/GerritSiteHeader.html'
    }

    file { "${gerrit_home}/etc/GerritSiteHeader.html":
      owner   => $gerrit_user,
      group   => $gerrit_user,
      source  => $gerrit_header,
      require => User[$gerrit_user],
    }

    ## GerritSiteFooter.html
    if has_key($gerrit_site_options, 'GerritSiteFooter.html') {
      validate_string($gerrit_site_options['GerritSiteFooter.html'])
      $gerrit_footer = $gerrit_site_options['GerritSiteFooter.html']
    }
    else {
      $gerrit_footer = 'puppet:///modules/gerrit/skin/GerritSiteFooter.html'
    }

    file { "${gerrit_home}/etc/GerritSiteFooter.html":
      owner   => $gerrit_user,
      group   => $gerrit_user,
      source  => $gerrit_footer,
      require => User[$gerrit_user],
    }
  }

  # manage static site content
  if $manage_static_site {
    # we need something, we can't easily check for all types of valid
    # File resource sources, but it should be something _other_ than ''
    if empty($static_source) {
      fail('No static_source defined for gerrit static site')
    }

    # we could still do a validate string but at this point we should be
    # pretty confidant we're dealing with something relatively valid
    file { "${gerrit_home}/static":
      ensure  => directory,
      owner   => $gerrit_user,
      group   => $gerrit_user,
      source  => $static_source,
      recurse => true,
      purge   => true,
      require => User[$gerrit_user],
    }
  }
  else {
    # we still want to make sure that ${gerrit_home}/static is created
    file { "${gerrit_home}/static":
      ensure  => directory,
      owner   => $gerrit_user,
      group   => $gerrit_user,
      require => User[$gerrit_user],
    }
  }


  # setup the installation directory structure and git storage
  $gitpath = $options['gerrit']['basePath']
  validate_absolute_path($gitpath)

  file { [
      "${gerrit_home}/bin",
      "${gerrit_home}/etc",
      "${gerrit_home}/lib",
      "${gerrit_home}/logs",
      "${gerrit_home}/plugins",
      "${gerrit_home}/tmp",
      $gitpath,
    ]:
    ensure  => directory,
    owner   => $gerrit_user,
    group   => $gerrit_user,
    require => User[$gerrit_user],
  }

  # download gerrit
  exec { "download gerrit ${gerrit_version}":
    cwd     => "${gerrit_home}/bin",
    path    => [ '/usr/bin', '/usr/sbin' ],
    command => "curl -s -O ${download_location}/gerrit-${gerrit_version}.war",
    creates => "${gerrit_home}/bin/gerrit-${gerrit_version}.war",
    user    => $gerrit_user,
    group   => $gerrit_user,
  }

  # install default plugins if needed
  if ($install_default_plugins) {
    file { "${gerrit_home}/extract_plugins":
      ensure  => directory,
      owner   => $gerrit_user,
      group   => $gerrit_user,
      require => User[$gerrit_user],
    }

    exec{ 'extract_plugins':
      cwd     => "${gerrit_home}/extract_plugins",
      path    => [ '/usr/bin', '/usr/sbin' ],
      command => "jar \
xf ${gerrit_home}/bin/gerrit-${gerrit_version}.war WEB-INF/plugins",
      creates => "${gerrit_home}/extract_plugins/WEB-INF/plugins",
      user    => $gerrit_user,
      group   => $gerrit_user,
      require => [
        File["${gerrit_home}/extract_plugins"],
        Exec["download gerrit ${gerrit_version}"]
      ],
    }

    gerrit::install::plugin_files { $plugin_list:
      gerrit_home => $gerrit_home,
      gerrit_user => $gerrit_user,
      require     => [
        File["${gerrit_home}/plugins"],
        Exec['extract_plugins']
      ],
    }
  }
}
