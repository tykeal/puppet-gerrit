require 'spec_helper'

describe 'gerrit::install::plugin_files', :type => :define do
  let(:title) { 'testplugin' }

  let(:params) {
    {
      'gerrit_home' => '/opt/gerrit',
      'gerrit_user' => 'gerrit',
    }
  }

  context 'good params' do
    it { is_expected.to contain_file('testplugin').with(
      'ensure' => 'file',
      'source' => '/opt/gerrit/extract_plugins/WEB-INF/plugins/testplugin.jar',
      'owner'  => 'gerrit',
      'group'  => 'gerrit',
    ) }
  end

  it 'should report an error if it gets a home that is not an absolute path' do
    params.merge!({ 'gerrit_home' => 'invalid_val' })

    expect { should compile }.to \
      raise_error(RSpec::Expectations::ExpectationNotMetError,
        /"invalid_val" is not an absolute path\./)
  end
end

# vim: sw=2 ts=2 sts=2 et :
