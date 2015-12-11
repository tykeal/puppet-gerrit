define gerrit::install::plugin_files (
  $gerrit_group,
  $gerrit_home,
  $gerrit_user
) {
  validate_string($gerrit_group)
  validate_absolute_path($gerrit_home)
  validate_string($gerrit_user)

  file { $name:
    ensure => file,
    group  => $gerrit_group,
    owner  => $gerrit_user,
    path   => "${gerrit_home}/plugins/${name}.jar",
    source =>
      "${gerrit_home}/extract_plugins/WEB-INF/plugins/${name}.jar",
  }
}
