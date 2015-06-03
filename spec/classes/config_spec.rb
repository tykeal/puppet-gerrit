require 'spec_helper'

describe 'gerrit::config', :type => :class do
  # setup some basic facts
  let(:facts) {
    {
      :fqdn => 'my.test.com',
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

  # With the 'assumed' defaults fall through from a basic 
  # include ::gerrit
  context 'with assumed default parameters' do
    let(:params) {
      {
        'db_tag'                      => 'test',
        'default_secure_options'      => {
          'auth'                      => {
            'registerEmailPrivateKey' => 'GENERATE',
            'restTokenPrivateKey'     => 'GENERATE',
          },
        },
        'gerrit_home'                 => '/opt/gerrit',
        'gerrit_site_options'         => {},
        'manage_database'             => true,
        'manage_firewall'             => true,
        'manage_site_skin'            => true,
        'manage_static_site'          => false,
        'options'                     => {
          'auth'                      => {
            'type'                    => 'OpenID',
          },
          'container'                 => {
            'user'                    => 'gerrit',
            'javaHome'                => '/usr/lib/jvm/jre',
          },
          'gerrit'                    => {
            'basePath'                => '/srv/gerrit',
          },
          'index'                     => {
            'type'                    => 'LUCENE',
          },
        },
        'override_secure_options'     => {},
        'static_source'               => '',
      }
    }

    it { is_expected.to contain_file('/opt/gerrit/etc/GerritSite.css').with(
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSite.css',
        ) }
    it { is_expected.to contain_file('/opt/gerrit/etc/GerritSiteHeader.html').with(
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSiteHeader.html',
        ) }
    it { is_expected.to contain_file('/opt/gerrit/etc/GerritSiteFooter.html',
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'source'  => 'puppet:///modules/gerrit/skin/GerritSiteFooter.html',
        ) }
    it { is_expected.to contain_file('/opt/gerrit/etc/gerrit.config').with(
        'ensure'  => 'file',
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'mode'    => '0660',
        ) }
    it { is_expected.to contain_file('/opt/gerrit/etc/secure.config').with(
        'ensure'  => 'file',
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'mode'    => '0600',
        'content' => "; MANAGED BY PUPPET\n\n[auth]\n\tregisterEmailPrivateKey = Hf8yvvCrs6dDBEc6WczhlEJD7rJGOHe7hr\n\trestTokenPrivateKey = 39v9y20F3nCQglWvDXFIXMCy9qORHWwxTO\n\n",
        ) }
    it { is_expected.to contain_gerrit__config__git_config('gerrit.config').with(
        'config_file' => '/opt/gerrit/etc/gerrit.config',
        'mode'        => '0660',
        ) }
    it { is_expected.to contain_file('gerrit_init_script').with(
        'ensure'  => 'link',
        'path'    => '/etc/init.d/gerrit',
        'target'  => '/opt/gerrit/bin/gerrit.sh',
        ) }
    it { is_expected.to contain_file('gerrit_defaults').with(
        'ensure'  => 'file',
        'owner'   => 'gerrit',
        'group'   => 'gerrit',
        'mode'    => '0644',
        'content' => "GERRIT_SITE=/opt/gerrit\n",
        ) }
    it { is_expected.to contain_class('gerrit::config::firewall') }
  end

  context 'should not have skins when manage_site_skin is false' do
    let(:params) {
      {
        'db_tag'                      => 'test',
        'default_secure_options'      => {
          'auth'                      => {
            'registerEmailPrivateKey' => 'GENERATE',
            'restTokenPrivateKey'     => 'GENERATE',
          },
        },
        'gerrit_home'                 => '/opt/gerrit',
        'gerrit_site_options'         => {},
        'manage_database'             => true,
        'manage_firewall'             => true,
        'manage_site_skin'            => false,
        'manage_static_site'          => false,
        'options'                     => {
          'auth'                      => {
            'type'                    => 'OpenID',
          },
          'container'                 => {
            'user'                    => 'gerrit',
            'javaHome'                => '/usr/lib/jvm/jre',
          },
          'gerrit'                    => {
            'basePath'                => '/srv/gerrit',
          },
          'index'                     => {
            'type'                    => 'LUCENE',
          },
        },
        'override_secure_options'     => {},
        'static_source'               => '',
      }
    }

    it { is_expected.to_not contain_file('/opt/gerrit/etc/GerritSite.css') }
    it { is_expected.to_not contain_file('/opt/gerrit/etc/GerritSiteHeader.html') }
    it { is_expected.to_not contain_file('/opt/gerrit/etc/GerritSiteFooter.html') }
  end

  context '' do
    let(:params) {
      {
        'db_tag'                      => 'test',
        'default_secure_options'      => {
          'auth'                      => {
            'registerEmailPrivateKey' => 'GENERATE',
            'restTokenPrivateKey'     => 'GENERATE',
          },
        },
        'gerrit_home'                 => '/var/foo',
        'gerrit_site_options'         => {
          'GerritSite.css'            => 'puppet:///private/GerritSite.css',
          'GerritSiteHeader.html'     => 'puppet:///private/GerritSiteHeader.html',
          'GerritSiteFooter.html'     => 'puppet:///private/GerritSiteFooter.html',
        },
        'manage_database'             => true,
        'manage_firewall'             => true,
        'manage_site_skin'            => true,
        'manage_static_site'          => false,
        'options'                     => {
          'auth'                      => {
            'type'                    => 'OpenID',
          },
          'container'                 => {
            'user'                    => 'foo',
            'javaHome'                => '/usr/lib/jvm/jre',
          },
          'gerrit'                    => {
            'basePath'                => '/srv/gerrit',
          },
          'index'                     => {
            'type'                    => 'LUCENE',
          },
        },
        'override_secure_options'     => {},
        'static_source'               => '',
      }
    }

    it { is_expected.to contain_file('/var/foo/etc/GerritSite.css').with(
      'owner'  => 'foo',
      'group'  => 'foo',
      'source' => 'puppet:///private/GerritSite.css',
    ) }

    it { is_expected.to contain_file('/var/foo/etc/GerritSiteHeader.html').with(
      'owner'  => 'foo',
      'group'  => 'foo',
      'source' => 'puppet:///private/GerritSiteHeader.html',
    ) }

    it { is_expected.to contain_file('/var/foo/etc/GerritSiteFooter.html').with(
      'owner'  => 'foo',
      'group'  => 'foo',
      'source' => 'puppet:///private/GerritSiteFooter.html',
    ) }
  end

  context 'should use defined values when override_secure_options is set' do
    let(:params) {
      {
        'db_tag'                      => 'test',
        'default_secure_options'      => {
          'auth'                      => {
            'registerEmailPrivateKey' => 'GENERATE',
            'restTokenPrivateKey'     => 'GENERATE',
          },
        },
        'gerrit_home'                 => '/opt/gerrit',
        'gerrit_site_options'         => {},
        'manage_database'             => true,
        'manage_firewall'             => true,
        'manage_site_skin'            => true,
        'manage_static_site'          => false,
        'options'                     => {
          'auth'                      => {
            'type'                    => 'OpenID',
          },
          'container'                 => {
            'user'                    => 'gerrit',
            'javaHome'                => '/usr/lib/jvm/jre',
          },
          'gerrit'                    => {
            'basePath'                => '/srv/gerrit',
          },
          'index'                     => {
            'type'                    => 'LUCENE',
          },
        },
        'override_secure_options'     => {
          'auth'                      => {
            'registerEmailPrivateKey' => 'foo',
            'restTokenPrivateKey'     => 'bar',
          },
        },
        'static_source'               => '',
      }
    }

    it { is_expected.to contain_file('/opt/gerrit/etc/secure.config').with(
      'content' => "; MANAGED BY PUPPET\n\n[auth]\n\tregisterEmailPrivateKey = foo\n\trestTokenPrivateKey = bar\n\n",
    ) }
  end

  context 'should raise an error if manage_static_site is true and no valid static_source' do
    let(:params) {
      {
        'db_tag'                      => 'test',
        'default_secure_options'      => {
          'auth'                      => {
            'registerEmailPrivateKey' => 'GENERATE',
            'restTokenPrivateKey'     => 'GENERATE',
          },
        },
        'gerrit_home'                 => '/opt/gerrit',
        'gerrit_site_options'         => {},
        'manage_database'             => true,
        'manage_firewall'             => true,
        'manage_site_skin'            => true,
        'manage_static_site'          => true,
        'options'                     => {
          'auth'                      => {
            'type'                    => 'OpenID',
          },
          'container'                 => {
            'user'                    => 'gerrit',
            'javaHome'                => '/usr/lib/jvm/jre',
          },
          'gerrit'                    => {
            'basePath'                => '/srv/gerrit',
          },
          'index'                     => {
            'type'                    => 'LUCENE',
          },
        },
        'override_secure_options'     => {
          'auth'                      => {
            'registerEmailPrivateKey' => 'foo',
            'restTokenPrivateKey'     => 'bar',
          },
        },
        'static_source'               => '',
      }
    }

    it { is_expected.to raise_error(Puppet::PreformattedError,
      /No static_source defined /) }
  end

  context 'should have a File resource for static_site' do
    let(:params) {
      {
        'db_tag'                      => 'test',
        'default_secure_options'      => {
          'auth'                      => {
            'registerEmailPrivateKey' => 'GENERATE',
            'restTokenPrivateKey'     => 'GENERATE',
          },
        },
        'gerrit_home'                 => '/opt/gerrit',
        'gerrit_site_options'         => {},
        'manage_database'             => true,
        'manage_firewall'             => true,
        'manage_site_skin'            => true,
        'manage_static_site'          => true,
        'options'                     => {
          'auth'                      => {
            'type'                    => 'OpenID',
          },
          'container'                 => {
            'user'                    => 'gerrit',
            'javaHome'                => '/usr/lib/jvm/jre',
          },
          'gerrit'                    => {
            'basePath'                => '/srv/gerrit',
          },
          'index'                     => {
            'type'                    => 'LUCENE',
          },
        },
        'override_secure_options'     => {
          'auth'                      => {
            'registerEmailPrivateKey' => 'foo',
            'restTokenPrivateKey'     => 'bar',
          },
        },
        'static_source'               => 'puppet:///static/site',
      }
    }

    it { is_expected.to contain_file('/opt/gerrit/static').with(
      'ensure'  => 'directory',
      'owner'   => 'gerrit',
      'group'   => 'gerrit',
      'source'  => 'puppet:///static/site',
      'recurse' => true,
      'purge'   => true,
    ) }
  end
end

# vim: sw=2 ts=2 sts=2 et :
