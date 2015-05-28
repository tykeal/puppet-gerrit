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
        'content' => "; MANAGED BY PUPPET\n\n[auth]\n\tregisterEmailPrivateKey = mScmLr+OfBFQVPwEWxwrqlF9lXa3j7ExDU\n\trestTokenPrivateKey = datdNYTYs7Msc097wHsCu2RhqGtm1TGj9l\n\n",
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

    # test not working?
    it 'should not have skins when manage_site_skin is false' do
      params.merge!({ 'manage_site_skin' => false })

      expect { should_not contain_file('/opt/gerrit/etc/GerritSite.css') }
      expect { should_not contain_file('/opt/gerrit/etc/GerritSiteHeader.html') }
      expect { should_not contain_file('/opt/gerrit/etc/GerritSiteFooter.html') }
    end

    # test not working?
    it 'should do custom skins with options set' do
      params.merge!({
        'gerrit_home' => '/var/foo',
      })
      params['options'].merge!({
        'container' => {
          'user' => 'foo'
        }
      })
      params['gerrit_site_options'].merge!({
        'GerritSite.css'        => 'puppet:///private/GerritSite.css',
        'GerritSiteHeader.html' => 'puppet:///private/GerritSiteHeader.html',
        'GerritSiteFooter.html' => 'puppet:///private/GerritSiteFooter.html',
      })

      expect { should contain_file('/var/foo/etc/GerritSite.css').with(
        'owner'  => 'foo',
        'group'  => 'foo',
        'source' => 'puppet:///private/GerritSite.css',
      ) }
      expect { should contain_file('/var/foo/etc/GerritSiteHeader.html').with(
        'owner'  => 'foo',
        'group'  => 'foo',
        'source' => 'puppet:///private/GerritSiteHeader.html',
      ) }
      expect { should contain_file('/var/foo/etc/GerritSiteFooter.html').with(
        'owner'  => 'foo',
        'group'  => 'foo',
        'source' => 'puppet:///private/GerritSiteFooter.html',
      ) }
    end

    # test not working?
    it 'should use defined values when override_secure_options is set' do
      params['override_secure_options'].merge!({
        'auth' => {
          'registerEmailPrivateKey' => 'foo',
          'restTokenPrivateKey' => 'bar'
        }
      })

      expect { should
        contain_file('/opt/gerrit/etc/secure.config').with(
          'content' => "; MANAGED BY PUPPET\n\n[auth]\n\tregisterEmailPrivateKey = foo\n\trestTokenPrivateKey = bar\n\n",
        ) }
    end
  end
end

# vim: sw=2 ts=2 sts=2 et :
