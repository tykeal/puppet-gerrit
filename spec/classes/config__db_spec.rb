require 'spec_helper'

describe 'gerrit::config::db', :type => :class do

  # we do not have default values so the class should fail compile
  context 'with defaults for all parameters' do
    let (:params) {{}}

    it do
      expect {
        should compile
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  # with mysql as the db
  context 'with mysql as database' do
    let(:params) {
      {
        'db_tag'          => 'test',
        'manage_database' => true,
        'options'         => {
          'database'      => {
            'type'        => 'MYSQL',
            'hostname'    => 'db.test.com',
            'database'    => 'gerrit',
            'username'    => 'gerrit',
          },
        },
        'secure_options'  => {
          'database'      => {
            'password'    => 'somepassword',
          },
        },
      }
    }

    it { is_expected.to contain_class('gerrit::config::db::mysql') }
  end

  context 'with postgresql as database' do
    let(:params) {
      {
        'db_tag'          => 'test',
        'manage_database' => true,
        'options'         => {
          'database'      => {
            'type'        => 'POSTGRESQL',
            'hostname'    => 'db.test.com',
            'database'    => 'gerrit',
            'username'    => 'gerrit',
          },
        },
        'secure_options'  => {
          'database'      => {
            'password'    => 'somepassword',
          },
        },
      }
    }

    it { is_expected.to contain_class('gerrit::config::db::postgresql') }
  end

end

# vim: sw=2 ts=2 sts=2 et :

