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
        'manage_database'             => true,
        'manage_firewall'             => true,
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
        'manage_database'             => true,
        'manage_firewall'             => true,
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
      }
    }

    it { is_expected.to contain_file('/opt/gerrit/etc/secure.config').with(
      'content' => "; MANAGED BY PUPPET\n\n[auth]\n\tregisterEmailPrivateKey = foo\n\trestTokenPrivateKey = bar\n\n",
    ) }
  end
end

# vim: sw=2 ts=2 sts=2 et :
