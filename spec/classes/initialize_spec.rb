require 'spec_helper'

describe 'gerrit::initialize', :type => :class do
  # set some default good params so we can override with bad ones during
  # testing
  let(:params) {
    {
      'gerrit_group'      => 'gerritgroup',
      'gerrit_home'       => '/opt/gerrit',
      'gerrit_user'       => 'gerrituser',
      'gerrit_version'    => '2.9.3',
      'options'           => {
        'auth'            => {
          'type'          => 'OpenID',
        },
        'container'       => {
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
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  # with assumed good params
  context 'with good parameters' do
    it { is_expected.to contain_exec('gerrit_initialize').with(
      'cwd'     => '/opt/gerrit',
      'command' => 'java -jar /opt/gerrit/bin/gerrit-2.9.3.war init -d /opt/gerrit --batch && java -jar /opt/gerrit/bin/gerrit.war reindex -d /opt/gerrit',
      'creates' => '/srv/gerrit/All-Projects.git/HEAD',
      'path'    => [ '/usr/bin', '/usr/sbin' ],
      'user'    => 'gerrituser',
    ) }
  end
end

# vim: sw=2 ts=2 sts=2 et :
