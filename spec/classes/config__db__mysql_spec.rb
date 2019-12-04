require 'spec_helper'

describe 'gerrit::config::db::mysql', :type => :class do

  # set some default good params so we can override with bad ones during
  # testing
  let(:params) {
    {
      'db_tag'          => 'test',
      'manage_database' => true,
      'options'         => {
        'auth'          => {
          'type'        => 'OpenID',
        },
        'container'     => {
          'user'        => 'gerrit',
          'javaHome'    => '/usr/lib/jvm/jre',
        },
        'database'      => {
          'type'        => 'MYSQL',
          'hostname'    => 'db.test.com',
          'database'    => 'gerrit',
          'username'    => 'gerrit',
        },
        'gerrit'        => {
          'basePath'    => '/srv/gerrit',
        },
        'index'         => {
          'type'        => 'LUCENE',
        },
      },
      'secure_options'  => {
        'database'      => {
          'password'    => 'somepassword',
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
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  # with assumed good params
  context 'with good parameters' do
    it { is_expected.to contain_class('gerrit::config::db::mysql') }

    # we can't test for exported resources :(
    #it { is_expected.to contain_class('mysql::db') }
  end

end

# vim: sw=2 ts=2 sts=2 et :
