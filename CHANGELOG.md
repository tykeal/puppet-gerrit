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
