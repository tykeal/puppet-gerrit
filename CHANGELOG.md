##2016-05-25 - v1.1.0 - Java Tuning

* Allow tuning of Java on systemd based systems (F21+ and EL7+) this was not
  initially supported. This will utilize the same options as the SysV init
  script for setting the heapLimit or other generic Java options.

##2016-03-16 - v1.0.0 - Roll up and bump to 1.0.0

* Breaking change! Puppet 4 is now required for the module.

* User and group managemnt is now optional - Bob Vincent

* Firewall rules now optionally support source address requirements - Jordan
  Evans

* Changes to support source address clamping are utilizing Puppet 4+ features to
  build out the proper firewall rule definition. As the syntax being introduced
  does not exist before Puppet 4 (or in puppet 3 with future_parser enabled) the
  supported Puppet version has been bumped to >= 4

* Make gitweb package configurable in support of folks installing packages that
  are not in the upstream repos (say for instance IUS) - Andrew Grimberg

##2015-12-03 - v0.9.4 - Silence wget::fetch notices

* Third party plugins were being downloaded into a cache directory which
  causes the wget exec to emit a notice on every puppet run. This notice
  does not occur if the download is happening in place (provided that
  the file isn't changing). This update fixes it so that the downloads
  happen in place, but only if needed.

* v0.9.3 introduced a cache directory as $gerrit_home/plugin_cache.
  Since this is no longer needed it is now being purged should it exist
  on disk. This purge will be removed with v1.0.0

##2015-12-02 - v0.9.3 - Add ability to deploy 3rd party plugins

* Make it possible to specify 3rd party plugins to install. Caveat on
  the plugins being raw jar files available on the system already (via a
  file source) in a puppet fileserver or available via HTTP(S).
  Configuration management for 3rd party config files already exists we
  just didn't have a way to manage deploying them.

##2015-10-30 - v0.9.2 - Fix up init scripts

* Make systemd based RH systems use a systemd init instead of the init.d
  script that ships with gerrit. This fixes issues with puppet
  constantly trying to ensure that the service is enabled on every run

##2015-10-30 - v0.9.1 - Update to fix firewall port usage

* Start using dport instead of the less specific port option in the
  firewall rules.

##2015-06-09 - Update to documentation and release
###Summary

* Update the docs to resolve Issue #6

* Release update metadata for release to version 0.9.0 it would be
  v1.0.0 if the postgresql exporting was working as the other issues
  currently logged are nice to haves and not requirements.

##2015-06-08 - Plugin management and extra config files
###Summary

* Resolve Issue #2, we can now install all or some of the shipped
  plugins (the all option is the list of plugins that shipped with
  v2.9.3 of Gerrit)

* Resolve Issue #11 as at least one of the shipped plugins needed to
  have a configuration file separate from the base gerrit and secure
  configuration files. It is now possible to manage any number of extra
  configuration. Removal of the files is not presently support, just the
  creation and managemnt of the file contents. These files do not cause
  a refresh of the Gerrit service.

##2015-06-04 - Support refresh of service on change to config files
###Summary

* Resolve Issue #10 where the gerrit service was not being refreshed
  when gerrit.config or secure.config were changed

##2015-06-03 - Support static site content push
###Summary

* Start supporting pushing of content to ~gerrit/static which is useful
  for any custom headers / footers that may be already pushed

##2015-05-28 - Refactor of code
###Summary

* Refactor to make clean up the rspec tests and make them work with
  latest version of rpsec

* Switch from built in fqdn_token_string_spec to puppetlabs/stdlib (>=
  v4.6.0) fqdn_rand_string function instead which is hopefully safer
  than what was locally created

##2015-01-07 - initial release of 0.1.0
