require 'spec_helper'

describe 'gerrit::install', :type => :class do

  # Force our osfamily & operatingsystem so that puppetlabs-java
  # doesn't croak on us
  let(:facts) { {
      :fqdn                   => 'my.test.com',
      :ipaddress              => '10.0.0.1',
      :osfamily               => 'RedHat',
      :operatingsystem        => 'Centos',
      :operatingsystemrelease => '6.0'
    } }

  # set some default good params so we can override with bad ones in
  # test (these are taken from gerrit::params.pp
  let(:params) {
    {
      'download_location'       => 'https://gerrit-releases.storage.googleapis.com',
      'gerrit_group'            => 'gerritgroup',
      'gerrit_home'             => '/opt/gerrit',
      'gerrit_site_options'     => {},
      'gerrit_user'             => 'gerrituser',
      'gerrit_version'          => '2.9.3',
      'install_default_plugins' => true,
      'install_git'             => true,
      'install_gitweb'          => true,
      'install_java'            => true,
      'manage_site_skin'        => true,
      'manage_static_site'      => false,
      'manage_user'             => true,
      'options'                 => {
        'auth'                  => {
          'type'                => 'OpenID',
        },
        'container'             => {
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
      'third_party_plugins'     => {},
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
    it { is_expected.to contain_group('gerritgroup') }
    it { is_expected.to contain_package('gitweb') }
    it { is_expected.to contain_user('gerrituser').with(
        'home' => '/opt/gerrit',
      ) }

    it { is_expected.to contain_file('gerrit_init_script').with(
        'ensure' => 'link',
        'path'   => '/etc/init.d/gerrit',
        'target' => "#{params['gerrit_home']}/bin/gerrit.sh",
      ) }

    it 'should have systemd service file for EL7+' do
      facts.merge!({
        :operatingsystemrelease => '7.0',
      })

      should contain_file('gerrit_init_script').with(
        'ensure' => 'absent',
        'path'   => '/etc/init.d/gerrit',
      ) 
      should contain_file('gerrit_systemd_script').with(
        'ensure'  => 'file',
        'path'    => '/usr/lib/systemd/system/gerrit.service',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'content' => "# WARNING THIS FILE IS MANAGED BY PUPPET
[Unit]
Description=Gerrit Code Review
After=network.target

[Service]
EnvironmentFile=/etc/default/gerritcodereview
SyslogIdentifier=gerrit
ExecStart=/usr/bin/java $JAVA_OPTIONS -jar #{params['gerrit_home']}/bin/gerrit.war daemon -d $GERRIT_SITE
User=#{params['gerrit_user']}
Group=#{params['gerrit_group']}

[Install]
WantedBy=multi-user.target
"
      )
    end

    it { is_expected.to contain_file('/opt/gerrit/etc/GerritSite.css').with(
        'owner'   => 'gerrituser',
        'group'   => 'gerritgroup',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSite.css',
        'require' => 'User[gerrituser]',
        ) }
    it { is_expected.to contain_file('/opt/gerrit/etc/GerritSiteHeader.html').with(
        'owner'   => 'gerrituser',
        'group'   => 'gerritgroup',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSiteHeader.html',
        'require' => 'User[gerrituser]',
        ) }
    it { is_expected.to contain_file('/opt/gerrit/etc/GerritSiteFooter.html',
        'owner'   => 'gerrituser',
        'group'   => 'gerritgroup',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSiteFooter.html',
        'require' => 'User[gerrituser]',
        ) }
    it { is_expected.to contain_file('/opt/gerrit/static').with(
        'ensure'  => 'directory',
        'owner'   => 'gerrituser',
        'group'   => 'gerritgroup',
        'require' => 'User[gerrituser]',
        ) }
    # only need to fully validate one file for properties since the
    # definition should be an array define for all the permissions
    # setting
    it { is_expected.to contain_file('/opt/gerrit/bin').with(
          'ensure'    => 'directory',
          'owner'     => 'gerrituser',
          'group'     => 'gerritgroup',
          'require'   => 'User[gerrituser]',
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
        'user'    => 'gerrituser',
        'group'   => 'gerritgroup',
        ) }

    # plugin extraction
    it { is_expected.to contain_file('/opt/gerrit/extract_plugins').with(
      'ensure'  => 'directory',
      'owner'   => 'gerrituser',
      'group'   => 'gerritgroup',
      'require' => 'User[gerrituser]',
      ) }
    it { is_expected.to contain_exec('extract_plugins').with(
      'cwd'     => '/opt/gerrit/extract_plugins',
      'path'    => [ '/usr/bin', '/usr/sbin' ],
      'command' => 'jar xf /opt/gerrit/bin/gerrit-2.9.3.war WEB-INF/plugins',
      'creates' => '/opt/gerrit/extract_plugins/WEB-INF/plugins',
      'user'    => 'gerrituser',
      'group'   => 'gerritgroup',
      'require' => [
          'File[/opt/gerrit/extract_plugins]',
          'Exec[download gerrit 2.9.3]'
        ],
      ) }

    # plugin installation
    it { is_expected.to contain_gerrit__install__plugin_files(
      'commit-message-length-validator').with(
        'gerrit_home' => '/opt/gerrit',
        'gerrit_user' => 'gerrituser',
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
      params.merge!({ 'gerrit_group' => 'bar', 'gerrit_home' => '/var/foo', 'gerrit_user'=> 'foo', })

      should contain_user('foo').with(
        'home' => '/var/foo',
      )

      should contain_file('/var/foo/etc/GerritSite.css').with(
        'owner'   => 'foo',
        'group'   => 'bar',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSite.css',
        'require' => 'User[foo]',
      )

      should contain_file('/var/foo/etc/GerritSiteHeader.html').with(
        'owner'   => 'foo',
        'group'   => 'bar',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSiteHeader.html',
        'require' => 'User[foo]',
      )

      should contain_file('/var/foo/etc/GerritSiteFooter.html',
        'owner'   => 'foo',
        'group'   => 'bar',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSiteFooter.html',
        'require' => 'User[foo]',
      )

      should contain_file('/var/foo/static').with(
        'ensure'  => 'directory',
        'owner'   => 'foo',
        'group'   => 'bar',
        'require' => 'User[foo]',
      )

      # only need to fully validate one file for properties since the
      # definition should be an array define for all the permissions
      # setting
      should contain_file('/var/foo/bin').with(
            'ensure'    => 'directory',
            'owner'     => 'foo',
            'group'     => 'bar',
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
          'group'   => 'bar',
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
        'owner'   => 'gerrituser',
        'group'   => 'gerritgroup',
        'source'  => 'puppet:///static/site',
        'recurse' => true,
        'purge'   => true,
      )
    end

    it 'should install third party plugins' do
      params.merge!({
        'third_party_plugins' => {
          'test-plugin'       => {
            'plugin_source'   =>
              'http://plugins.foo/test-plugin.jar',
          },
        },
      })

      should contain_gerrit__install__third_party_plugin(
        'test-plugin').with(
        'gerrit_home'   => params['gerrit_home'],
        'gerrit_user'   => 'gerrituser',
        'plugin_source' => 'http://plugins.foo/test-plugin.jar',
      )
    end
  end

  context 'with limited plugins' do
    let(:params) {
      {
        'download_location'       => 'https://gerrit-releases.storage.googleapis.com',
        'gerrit_group'            => 'gerritgroup',
        'gerrit_home'             => '/opt/gerrit',
        'gerrit_site_options'     => {},
        'gerrit_user'             => 'gerrituser',
        'gerrit_version'          => '2.9.3',
        'install_default_plugins' => true,
        'install_git'             => true,
        'install_gitweb'          => true,
        'install_java'            => true,
        'manage_site_skin'        => true,
        'manage_static_site'      => false,
        'manage_user'             => true,
        'options'                 => {
          'auth'                  => {
            'type'                => 'OpenID',
          },
          'container'             => {
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
        'third_party_plugins'     => {},
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
