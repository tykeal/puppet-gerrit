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
      cache_dir   => "${gerrit_home}/plugin_cache",
      timeout     => 0,
      verbose     => false,
      require     => File["${gerrit_home}/plugin_cache"],
    }

    ensure_resource('file', "${gerrit_home}/plugin_cache",
      { 'ensure' => 'directory', 'owner' => $gerrit_user })
  }
}
