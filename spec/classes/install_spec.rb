require 'spec_helper'

describe 'gerrit::install', :type => :class do

  # Force our osfamily & operatingsystem so that puppetlabs-java
  # doesn't croak on us
  let(:facts) { {
      :fqdn             => 'my.test.com',
      :ipaddress        => '10.0.0.1',
      :osfamily         => 'RedHat',
      :operatingsystem  => 'Centos'
    } }

  # set some default good params so we can override with bad ones in
  # test (these are taken from gerrit::params.pp
  let(:params) {
    {
      'download_location' => 'https://gerrit-releases.storage.googleapis.com',
      'gerrit_home'       => '/opt/gerrit',
      'gerrit_version'    => '2.9.3',
      'install_git'       => true,
      'install_gitweb'    => true,
      'install_java'      => true,
      'options'           => {
        'auth'            => {
          'type'          => 'OpenID',
        },
        'container'       => {
          'user'          => 'gerrit',
          'javaHome'      => '/usr/lib/jvm/jre',
        },
        'gerrit'          => {
          'basePath'      => '/srv/gerrit',
        },
        'index'           => {
          'type'          => 'LUCENE',
        },
      },
    }
  }

  # we do not have default values so the class should fail compile
  context 'with defaults for all parameters' do
    let (:params) {{}}

    it do
      expect {
        should compile
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
        /Must pass /)
    end
  end

  # with assumed good params
  context 'with good parameters' do
    it { is_expected.to contain_class('java') }
    it { is_expected.to contain_class('git') }
    it { is_expected.to contain_package('gitweb') }
    it { is_expected.to contain_user('gerrit').with(
        'home' => '/opt/gerrit',
      ) }

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
    it { is_expected.to contain_file('/srv/gerrit') }
    it { is_expected.to contain_exec('download gerrit 2.9.3').with(
        'cwd'     => '/opt/gerrit/bin',
        'path'    => [ '/usr/bin', '/usr/sbin' ],
        'command' => 'curl -s -O https://gerrit-releases.storage.googleapis.com/gerrit-2.9.3.war',
        'creates' => '/opt/gerrit/bin/gerrit-2.9.3.war',
        'user'    => 'gerrit',
        'group'   => 'gerrit',
        ) }

    it 'should not have java when install_java is false' do
      params.merge!({'install_java' => false})

      should_not contain_class('java')
    end

    it 'should not have git when install_git is false' do
      params.merge!({'install_git' => false})

      should_not contain_class('git')
    end

    it 'should not have gitweb when install_gitweb is false' do
      params.merge!({'install_gitweb' => false})

      should_not contain_package('gitweb')
    end
  end

end

# vim: sw=2 ts=2 sts=2 et :
