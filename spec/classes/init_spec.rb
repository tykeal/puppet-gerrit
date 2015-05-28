require 'spec_helper'

describe 'gerrit', :type => :class do

  # Force our osfamily & operatingsystem so that puppetlabs-java
  # doesn't croak on us
  let(:facts) { {
      :fqdn             => 'my.test.com',
      :ipaddress        => '10.0.0.1',
      :osfamily         => 'RedHat',
      :operatingsystem  => 'Centos'
    } }

  context 'with defaults' do
    it { is_expected.to contain_class('gerrit') }
    it { is_expected.to contain_class('gerrit::params') }
    it { is_expected.to contain_anchor('gerrit::begin') }
    it { is_expected.to contain_class('gerrit::install') }
    it { is_expected.to contain_class('gerrit::config') }
    it { is_expected.to contain_class('gerrit::initialize') }
    it { is_expected.to contain_class('gerrit::service') }
    it { is_expected.to contain_anchor('gerrit::end') }
  end
end

# vim: sw=2 ts=2 sts=2 et :

