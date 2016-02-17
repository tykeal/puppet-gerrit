require 'rspec-puppet-facts'
require 'puppetlabs_spec_helper/module_spec_helper'

include RspecPuppetFacts
RSpec.configure do |config|
  config.formatter = :documentation
end
