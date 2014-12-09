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
# This class accepts no variables directly
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2014 Andrew Grimberg
#
class gerrit::config {
  $options = $gerrit::options

  $gerrit_home = $gerrit::gerrit_home
  $gerrit_user = $options['container']['user']['value']
  validate_string($gerrit_user)

  # install gerrit site skin bits
  if ($gerrit::manage_site_skin) {
    # determine if any useful site options were passed
    $gerrit_site_options = $gerrit::gerrit_site_options

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

  # gerrit configuration
  file { "${gerrit_home}/etc/gerrit.config":
    ensure => present,
    owner  => $gerrit_user,
    group  => $gerrit_user,
    mode   => '0660',
  }

  file { "${gerrit_home}/etc/secure.config":
    ensure => present,
    owner  => $gerrit_user,
    group  => $gerrit_user,
    mode   => '0600',
  }
}
