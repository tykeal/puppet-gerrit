# == Class: gerrit
#
# This class is the entry point into installing and configuring a Gerrit
# server
#
# === Parameters
#
# [*download_location*]
#   Base location for downloading the Gerrit war from
#
# [*gerrit_version*]
#   The version of the Gerrit war that will be downloaded
#
# [*install_git*]
#   Should this module make sure that git is installed? (NOTE: a git
#   installation is required for Gerrit to be able to operate)
#
# [*install_java*]
#   Should this module make sure that a jre is installed? (NOTE: a jre
#   installation is required for Gerrit to operate)
#
# [*override_options*]
#   A variable hash for configuration settings of Gerrit. Please see
#   gerrit::params for the default_options hash
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
  $download_location  = $gerrit::params::download_location,
  $gerrit_home        = $gerrit::params::gerrit_home,
  $gerrit_version     = $gerrit::params::gerrit_version,
  $install_git        = $gerrit::params::install_git,
  $install_java       = $gerrit::params::install_java,
  $override_options   = {}
) inherits gerrit::params {

  # Make sure that all of the params are properly formated
  validate_string($download_location)
  validate_absolute_path($gerrit_home)
  validate_string($gerrit_version)
  validate_bool($install_git)
  validate_bool($install_java)
  validate_hash($override_options)

  # Create a merged together set of options. Rightmost hashes win over left.
  $options = merge($gerrit::params::default_options, $override_options)
  validate_hash($options)

  anchor { 'gerrit::begin': }
  anchor { 'gerrit::end': }

  include '::gerrit::install'
  include '::gerrit::config'
  include '::gerrit::service'

  Anchor['gerrit::begin'] ->
    Class['gerrit::install'] ->
    Class['gerrit::config'] ->
    Class['gerrit::service'] ->
  Anchor['gerrit::end']
}
