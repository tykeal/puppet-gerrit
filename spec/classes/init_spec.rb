require 'spec_helper'

describe 'gerrit' do

  # Force our osfamily & operatingsystem so that puppetlabs-java
  # doesn't croak on us
  let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'Centos'} }

  context 'with defaults' do
    it { is_expected.to contain_class('gerrit') }
    it { is_expected.to contain_class('gerrit::params') }
    it { is_expected.to contain_anchor('gerrit::begin') }
    it { is_expected.to contain_class('gerrit::install') }
    it { is_expected.to contain_class('gerrit::config') }
    it { is_expected.to contain_class('gerrit::service') }
    it { is_expected.to contain_anchor('gerrit::end') }
  end

  #####
  # gerrit::install testing
  #####

  # this would be in a separate install_spec.rb but cross sub-module
  # variable evaluation doesn't seem to work correctly then
  context 'gerrit::install' do
    it { is_expected.to contain_class('java') }
    it { is_expected.to contain_class('git') }
    it { is_expected.to contain_user('gerrit') }

    # only need to fully validate one file for properties since the
    # definition should be an array define for all the permissions
    # setting
    it { is_expected.to contain_file('/opt/gerrit/bin').with(
          'ensure'    => 'directory',
          'owner'     => 'gerrit',
          'group'     => 'gerrit',
          'require'   => 'User[gerrit]',
          ) }
    it { is_expected.to contain_file('/opt/gerrit/etc') }
    it { is_expected.to contain_file('/opt/gerrit/lib') }
    it { is_expected.to contain_file('/opt/gerrit/logs') }
    it { is_expected.to contain_file('/opt/gerrit/plugins') }
    it { is_expected.to contain_file('/opt/gerrit/static') }
    it { is_expected.to contain_file('/opt/gerrit/tmp') }
    it { is_expected.to contain_exec('download gerrit 2.9.2') }
    it { is_expected.to contain_exec('download gerrit 2.9.2').with(
        'cwd'     => '/opt/gerrit',
        'path'    => [ '/usr/bin', '/usr/sbin' ],
        'command' => 'curl -s -O https://gerrit-releases.storage.googleapis.com/gerrit-2.9.2.war',
        'creates' => '/opt/gerrit/gerrit-2.9.2.war',
        'user'    => 'gerrit',
        'group'   => 'gerrit',
        ) }
  end

  context 'with install_java false' do
    let(:params) {{ :install_java => false }}
    it { is_expected.to_not contain_class('java') }
  end

  context 'with install_git false' do
    let(:params) {{ :install_git => false }}
    it { is_expected.to_not contain_class('git') }
  end

  context 'with options[container][user][value] set to foo' do
    let(:params) {{ :override_options => {
      'container' => { 'user' => {'value' => 'foo' }}} }}
    it { is_expected.to contain_user('foo') }

    # only need to fully validate one file for properties since the
    # definition should be an array define for all the permissions
    # setting
    it { is_expected.to contain_file('/opt/gerrit/bin').with(
          'ensure'    => 'directory',
          'owner'     => 'foo',
          'group'     => 'foo',
          'require'   => 'User[foo]',
          ) }

    it { is_expected.to contain_exec('download gerrit 2.9.2').with(
        'user'  => 'foo',
        'group' => 'foo',
        ) }
  end

  # really only need to fully validate one file path since we've made sure
  # that changing the user modifies all owner, group, require already
  context 'with gerrit_home set to /var/foo' do
    let(:params) {{ :gerrit_home => '/var/foo' }}
    it { is_expected.to contain_user('gerrit').with(
          'home' => '/var/foo',
        ) }
    it { is_expected.to contain_file('/var/foo/bin').with(
          'ensure'    => 'directory',
          'owner'     => 'gerrit',
          'group'     => 'gerrit',
          'require'   => 'User[gerrit]',
        ) }
    it { is_expected.to contain_file('/var/foo/etc') }
    it { is_expected.to contain_file('/var/foo/lib') }
    it { is_expected.to contain_file('/var/foo/logs') }
    it { is_expected.to contain_file('/var/foo/plugins') }
    it { is_expected.to contain_file('/var/foo/static') }
    it { is_expected.to contain_file('/var/foo/tmp') }
    it { is_expected.to contain_exec('download gerrit 2.9.2').with(
        'cwd' => '/var/foo',
        'creates' => '/var/foo/gerrit-2.9.2.war',
        ) }
  end

  context 'with gerrit_version 2.10.0 and download_location http://foo' do
    let(:params) {{ :gerrit_version => '2.10.0', :download_location => 'http://foo' }}
    it { is_expected.to contain_exec('download gerrit 2.10.0').with(
        'command' => 'curl -s -O http://foo/gerrit-2.10.0.war',
        'creates' => '/opt/gerrit/gerrit-2.10.0.war',
        ) }
  end

  #####
  # gerrit::config testing
  #####
end
