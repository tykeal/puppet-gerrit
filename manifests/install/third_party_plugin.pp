# == Define: gerrit::install::third_party_plugin
#
# This define is used for fetching and installing 3rd party plugins into
# Gerrit
#
# === Variables
#
# [*gerrit_home*]
#   The home directory where Gerrit is being installed
#
# [*gerrit_user*]
#   The user that gerrit is using
#
# [*plugin_source*]
#   An appropriate fully qualified resource locator.
#
#   Valid resource types are file puppet and http(s)
#
# === Examples
#
# gerrit::install::third_party_plugin { 'delete-project':
#   gerrit_home   => '/opt/gerrit',
#   gerrit_user   => 'gerrit',
#   plugin_source =>
#   'https://gerrit-ci.gerritforge.com/view/Plugins-stable-2.11/job/plugin-delete-project-stable-2.11/lastSuccessfulBuild/artifact/buck-out/gen/plugins/delete-project/delete-project.jar',
# }
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyriight 2015 Andrew Grimberg
#
# === License
#
# @License Apache-2.0 <http://spdx.org/licenses/Apache-2.0.html>
#
define gerrit::install::third_party_plugin (
  $gerrit_home,
  $gerrit_user,
  $plugin_source
) {
  validate_absolute_path($gerrit_home)
  validate_string($gerrit_user)
  validate_re($plugin_source, [ '^file:', '^puppet:', '^https?:' ])

  if $plugin_source =~ /^(file|puppet)/ {
    # source plugin for a local file or puppet fileserver
    file { $name:
      ensure => file,
      path   => "${gerrit_home}/plugins/${name}.jar",
      source => $plugin_source,
      owner  => $gerrit_user,
      group  => $gerrit_user,
    }
  } else {
    # Plugin is sourced from external resource
    include ::wget

    ::wget::fetch { "download ${name} gerrit plugin":
      source      => $plugin_source,
      destination => "${gerrit_home}/plugins/${name}.jar",
      flags       => ['--timestamping'],
      timeout     => 0,
      verbose     => false,
    }

    # v0.9.3 used a cache_dir with fetch. Unfortunately that had an
    # annoying side effect of always producing a notice when the fetch
    # ran. While not troubling to some people, those using tagmail (or
    # similar) would always be getting alerts. Since the plugins are
    # always a single file using timestamping retrieval and placing it
    # directly will silence the notice.
    #
    # The following resource removal will be removed with v1.0.0 as
    # anyone still using the module will hopefully have stepped through
    # a version that removed it.
    ensure_resource('file', "${gerrit_home}/plugin_cache",
      { 'ensure' => 'absent', 'purge' => true, 'force' => true })
  }
}
