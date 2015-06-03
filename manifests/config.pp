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
class gerrit::config (
  $db_tag,
  $default_secure_options,
  $gerrit_home,
  $gerrit_site_options,
  $manage_database,
  $manage_firewall,
  $manage_site_skin,
  $manage_static_site,
  $options,
  $override_secure_options,
  $static_source
) {
  validate_string($db_tag)
  validate_hash($default_secure_options)
  validate_absolute_path($gerrit_home)
  validate_hash($gerrit_site_options)
  validate_bool($manage_database)
  validate_bool($manage_firewall)
  validate_bool($manage_site_skin)
  validate_bool($manage_static_site)
  validate_hash($options)
  validate_hash($override_secure_options)
  validate_string($static_source)

  $gerrit_user = $options['container']['user']
  validate_string($gerrit_user)

  anchor { 'gerrit::config::begin': }
  anchor { 'gerrit::config::end': }

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
      owner  => $gerrit_user,
      group  => $gerrit_user,
      source => $gerrit_css,
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
      owner  => $gerrit_user,
      group  => $gerrit_user,
      source => $gerrit_header,
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
      owner  => $gerrit_user,
      group  => $gerrit_user,
      source => $gerrit_footer,
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
    }
  }
  else {
    # we still want to make sure that ${gerrit_home}/static is created
    file { "${gerrit_home}/static":
      ensure => directory,
      owner  => $gerrit_user,
      group  => $gerrit_user,
    }
  }

  # link up the service script
  file { 'gerrit_init_script':
    ensure => link,
    path   => '/etc/init.d/gerrit',
    target => "${gerrit_home}/bin/gerrit.sh",
  }

  # we need an /etc/default/gerritcodereview file to specify the
  # gerrit_home
  file { 'gerrit_defaults':
    ensure  => file,
    path    => '/etc/default/gerritcodereview',
    owner   => $gerrit_user,
    group   => $gerrit_user,
    mode    => '0644',
    content => template('gerrit/gerrit_defaults.erb'),
  }

  # gerrit configuration
  ::gerrit::config::git_config { 'gerrit.config':
    config_file => "${gerrit_home}/etc/gerrit.config",
    mode        => '0660',
    options     => $options,
  }

  # the secure options
  # auth.{registerEmailPrivateKey,restTokenPrivateKey} vars have the
  # option to be auto-generated using the create_token_string function.
  # If their values are set to GENERATE we need to do so
  $generate_secure_options = {
    'auth'                      => {
      'registerEmailPrivateKey' => fqdn_rand_string(34, '',
        'registerEmailPrivateKey'),
      'restTokenPrivateKey'     => fqdn_rand_string(34, '',
        'restTokenPrivateKey'),
    },
  }

  $generated_default_secure_options = merge($default_secure_options,
    $generate_secure_options)
  $real_secure_options = merge($generated_default_secure_options,
    $override_secure_options)

  ::gerrit::config::git_config { 'secure.config':
    config_file => "${gerrit_home}/etc/secure.config",
    mode        => '0600',
    options     => $real_secure_options,
  }

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
