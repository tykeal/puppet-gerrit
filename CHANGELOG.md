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
