define gerrit::install::plugin_files (
  $gerrit_home,
  $gerrit_user
) {
  validate_absolute_path($gerrit_home)
  validate_string($gerrit_user)

  file { $name:
    ensure => file,
    source =>
      "${gerrit_home}/extract_plugins/WEB-INF/plugins/${name}.jar",
    owner  => $gerrit_user,
    group  => $gerrit_user,
  }
}
