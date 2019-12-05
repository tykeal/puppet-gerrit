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
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
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
            # encode results of running fqdn_rand_string for test
            'registerEmailPrivateKey' => '0vYmIO6CeAzI2wVWroMQjG6jHQaz35sqtx',
            'restTokenPrivateKey'     => 'S7yu4FuMPH5NYrp1vLMFPm2PgG4nNKfJVw',
          },
        },
        'extra_configs'               => {},
        'gerrit_group'                => 'gerritgroup',
        'gerrit_home'                 => '/opt/gerrit',
        'gerrit_user'                 => 'gerrituser',
        'manage_database'             => true,
        'manage_firewall'             => true,
        'options'                     => {
          'auth'                      => {
            'type'                    => 'OpenID',
          },
          'container'                 => {
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
        'owner'   => 'gerrituser',
        'group'   => 'gerritgroup',
        'mode'    => '0660',
        ) }
    it { is_expected.to contain_file('/opt/gerrit/etc/secure.config').with(
        'ensure'  => 'file',
        'owner'   => 'gerrituser',
        'group'   => 'gerritgroup',
        'mode'    => '0600',
        'content' => "; MANAGED BY PUPPET\n\n[auth]\n\tregisterEmailPrivateKey = 0vYmIO6CeAzI2wVWroMQjG6jHQaz35sqtx\n\trestTokenPrivateKey = S7yu4FuMPH5NYrp1vLMFPm2PgG4nNKfJVw\n\n",
        ) }
    it { is_expected.to contain_gerrit__config__git_config('gerrit.config').with(
        'config_file' => '/opt/gerrit/etc/gerrit.config',
        'mode'        => '0660',
        ) }
    it { is_expected.to_not contain_file('gerrit_defaults') }
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
        'extra_configs'               => {},
        'gerrit_group'                => 'gerritgroup',
        'gerrit_home'                 => '/opt/gerrit',
        'gerrit_user'                 => 'gerrituser',
        'manage_database'             => true,
        'manage_firewall'             => true,
        'options'                     => {
          'auth'                      => {
            'type'                    => 'OpenID',
          },
          'container'                 => {
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

  context 'with extra_configs defined it should have extra resources' do
    let(:params) {
      {
        'db_tag'                      => 'test',
        'default_secure_options'      => {
          'auth'                      => {
            'registerEmailPrivateKey' => 'GENERATE',
            'restTokenPrivateKey'     => 'GENERATE',
          },
        },
        'extra_configs'               => {
          'extra_config1'             => {
            'config_file'             => '/opt/gerrit/etc/extra.config',
            'mode'                    => '0644',
            'options'                 => {
              'section1'              => {
                'option1'             => [
                    'my option 1',
                    'second iteration of option 1',
                ],
              },
              'section2.foo'          => {
                'option2'             => 'This is in section2 "foo"',
              },
            },
          },
          'extra_config2'             => {
            'config_file'             => '/opt/gerrit/etc/extra2.config',
            'mode'                    => '0644',
            'options'                 => {
              'section1'              => {
                'option1'             => 'the only option',
              },
            },
          },
        },
        'gerrit_group'                => 'gerritgroup',
        'gerrit_home'                 => '/opt/gerrit',
        'gerrit_user'                 => 'gerrituser',
        'manage_database'             => true,
        'manage_firewall'             => true,
        'options'                     => {
          'auth'                      => {
            'type'                    => 'OpenID',
          },
          'container'                 => {
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

    it { is_expected.to contain_gerrit__config__git_config(
      'extra_config1').with(
        'config_file'          => '/opt/gerrit/etc/extra.config',
        'mode'                 => '0644',
        'options'              => {
          'section1'           => {
            'option1'          => [
                'my option 1',
                'second iteration of option 1',
            ],
          },
          'section2.foo'       => {
            'option2'          => 'This is in section2 "foo"',
          },
        },
      ) }

    it { is_expected.to contain_gerrit__config__git_config(
      'extra_config2').with(
        'config_file' => '/opt/gerrit/etc/extra2.config',
        'mode'        => '0644',
        'options'     => {
          'section1'  => {
            'option1' => 'the only option',
          },
        },
      ) }
  end
end
# vim: sw=2 ts=2 sts=2 et :
