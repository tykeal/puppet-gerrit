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
      'download_location'       => 'https://gerrit-releases.storage.googleapis.com',
      'gerrit_home'             => '/opt/gerrit',
      'gerrit_site_options'     => {},
      'gerrit_version'          => '2.9.3',
      'install_default_plugins' => true,
      'install_git'             => true,
      'install_gitweb'          => true,
      'install_java'            => true,
      'manage_site_skin'        => true,
      'manage_static_site'      => false,
      'options'                 => {
        'auth'                  => {
          'type'                => 'OpenID',
        },
        'container'             => {
          'user'                => 'gerrit',
          'javaHome'            => '/usr/lib/jvm/jre',
        },
        'gerrit'                => {
          'basePath'            => '/srv/gerrit',
        },
        'index'                 => {
          'type'                => 'LUCENE',
        },
      },
      'plugin_list'             => [
        'commit-message-length-validator',
        'download-commands',
        'replication',
        'reviewnotes'
      ],
      'static_source'           => '',
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

    it { is_expected.to contain_file('/opt/gerrit/etc/GerritSite.css').with(
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSite.css',
        'require' => 'User[gerrit]',
        ) }
    it { is_expected.to contain_file('/opt/gerrit/etc/GerritSiteHeader.html').with(
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSiteHeader.html',
        'require' => 'User[gerrit]',
        ) }
    it { is_expected.to contain_file('/opt/gerrit/etc/GerritSiteFooter.html',
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSiteFooter.html',
        'require' => 'User[gerrit]',
        ) }
    it { is_expected.to contain_file('/opt/gerrit/static').with(
        'ensure'  => 'directory',
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'require' => 'User[gerrit]',
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

    # plugin extraction
    it { is_expected.to contain_file('/opt/gerrit/extract_plugins').with(
      'ensure'  => 'directory',
      'owner'   => 'gerrit',
      'group'   => 'gerrit',
      'require' => 'User[gerrit]',
      ) }
    it { is_expected.to contain_exec('extract_plugins').with(
      'cwd'     => '/opt/gerrit/extract_plugins',
      'path'    => [ '/usr/bin', '/usr/sbin' ],
      'command' => 'jar xf /opt/gerrit/bin/gerrit-2.9.3.war WEB-INF/plugins',
      'creates' => '/opt/gerrit/extract_plugins/WEB-INF/plugins',
      'user'    => 'gerrit',
      'group'   => 'gerrit',
      'require' => [
          'File[/opt/gerrit/extract_plugins]',
          'Exec[download gerrit 2.9.3]'
        ],
      ) }

    # plugin installation
    it { is_expected.to contain_gerrit__install__plugin_files(
      'commit-message-length-validator').with(
        'gerrit_home' => '/opt/gerrit',
        'gerrit_user' => 'gerrit',
        'require'     => [
          'File[/opt/gerrit/plugins]',
          'Exec[extract_plugins]'
        ],
    ) }
    it { is_expected.to contain_gerrit__install__plugin_files(
      'download-commands') }
    it { is_expected.to contain_gerrit__install__plugin_files(
      'replication') }
    it { is_expected.to contain_gerrit__install__plugin_files(
      'reviewnotes') }

    it 'should not have any plugins if install_default_plugins is false' do
      params.merge!({ 'install_default_plugins' => false })

      should_not contain_gerrit__install__plugin__files('commit-message-length-validator')
      should_not contain_gerrit__install__plugin__files('download-commands')
      should_not contain_gerrit__install__plugin__files('replication')
      should_not contain_gerrit__install__plugin__files('reviewnotes')
    end

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

    it 'should not have skins when manage_site_skin is false' do
      params.merge!({'manage_site_skin' => false})

      should_not contain_file('/opt/gerrit/etc/GerritSite.css')
      should_not contain_file('/opt/gerrit/etc/GerritSiteHeader.html')
      should_not contain_file('/opt/gerrit/etc/GerritSiteFooter.html')
    end

    it 'should have different layout when gerrit_user & gerrit_home differ' do
      params.merge!({ 'gerrit_home' => '/var/foo' })
      params['options']['container'].merge!({ 'user' => 'foo' })

      should contain_user('foo').with(
        'home' => '/var/foo',
      )

      should contain_file('/var/foo/etc/GerritSite.css').with(
        'owner'   => 'foo',
        'group'   => 'foo',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSite.css',
        'require' => 'User[foo]',
      )

      should contain_file('/var/foo/etc/GerritSiteHeader.html').with(
        'owner'   => 'foo',
        'group'   => 'foo',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSiteHeader.html',
        'require' => 'User[foo]',
      )

      should contain_file('/var/foo/etc/GerritSiteFooter.html',
        'owner'   => 'foo',
        'group'   => 'foo',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSiteFooter.html',
        'require' => 'User[foo]',
      )

      should contain_file('/var/foo/static').with(
        'ensure'  => 'directory',
        'owner'   => 'foo',
        'group'   => 'foo',
        'require' => 'User[foo]',
      )

      # only need to fully validate one file for properties since the
      # definition should be an array define for all the permissions
      # setting
      should contain_file('/var/foo/bin').with(
            'ensure'    => 'directory',
            'owner'     => 'foo',
            'group'     => 'foo',
            'require'   => 'User[foo]',
      )

      should contain_file('/var/foo/etc')
      should contain_file('/var/foo/lib')
      should contain_file('/var/foo/logs')
      should contain_file('/var/foo/plugins')
      should contain_file('/var/foo/tmp')
      should contain_file('/srv/gerrit')
      should contain_exec('download gerrit 2.9.3').with(
          'cwd'     => '/var/foo/bin',
          'path'    => [ '/usr/bin', '/usr/sbin' ],
          'command' => 'curl -s -O https://gerrit-releases.storage.googleapis.com/gerrit-2.9.3.war',
          'creates' => '/var/foo/bin/gerrit-2.9.3.war',
          'user'    => 'foo',
          'group'   => 'foo',
      )
    end

    it 'should raise an error if manage_static_site is true and no valid static_source' do
      params.merge!({ 'manage_static_site' => true })

      should raise_error(Puppet::Error,
        /No static_source defined /)
    end

    it 'should have a File resource for static_site' do
      params.merge!({ 'manage_static_site' => true })
      params.merge!({ 'static_source' => 'puppet:///static/site' })

      should contain_file('/opt/gerrit/static').with(
        'ensure'  => 'directory',
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'source'  => 'puppet:///static/site',
        'recurse' => true,
        'purge'   => true,
      )
    end
  end

  context 'with limited plugins' do
    let(:params) {
      {
        'download_location'       => 'https://gerrit-releases.storage.googleapis.com',
        'gerrit_home'             => '/opt/gerrit',
        'gerrit_site_options'     => {},
        'gerrit_version'          => '2.9.3',
        'install_default_plugins' => true,
        'install_git'             => true,
        'install_gitweb'          => true,
        'install_java'            => true,
        'manage_site_skin'        => true,
        'manage_static_site'      => false,
        'options'                 => {
          'auth'                  => {
            'type'                => 'OpenID',
          },
          'container'             => {
            'user'                => 'gerrit',
            'javaHome'            => '/usr/lib/jvm/jre',
          },
          'gerrit'                => {
            'basePath'            => '/srv/gerrit',
          },
          'index'                 => {
            'type'                => 'LUCENE',
          },
        },
        'plugin_list'             => [
          'reviewnotes'
        ],
        'static_source'           => '',
      }
    }

    it { is_expected.to contain_gerrit__install__plugin_files(
      'reviewnotes') }

    it { is_expected.to_not contain_gerrit__install__plugin_files(
      'commit-message-length-validator') }
    it { is_expected.to_not contain_gerrit__install__plugin_files(
      'download-commands') }
    it { is_expected.to_not contain_gerrit__install__plugin_files(
      'replication') }
  end
end

# vim: sw=2 ts=2 sts=2 et :
