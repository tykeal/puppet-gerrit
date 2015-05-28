##2015-05-28 - Refactor of code
###Summary

* Refactor to make clean up the rspec tests and make them work with
  latest version of rpsec

* Switch from built in fqdn_token_string_spec to puppetlabs/stdlib (>=
  v4.6.0) fqdn_rand_string function instead which is hopefully safer
  than what was locally created

##2015-01-07 - initial release of 0.1.0
