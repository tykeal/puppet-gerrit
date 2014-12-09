require 'spec_helper'

describe 'gerrit::config::git_config', :type => :define do
  let(:title) { 'test_git_config' }

  let(:params) {
    {
      'config_file' => '/opt/test.config',
      'section'     => 'testsection',
      'variable'    => 'testvariable',
      'value'       => 'testvalue',
    }
  }

  it 'should report an error when ensure is not present or absent' do
    params.merge!({'ensure' => 'invalid_val'})
    expect { subject }.to raise_error(Puppet::Error,
                                      /invalid_val is not supported for ensure\. Allowed values are 'present' and 'absent'\./)
  end

  it 'should report an error when config_file does not end in .config' do
    params.merge!({'config_file' => 'invalid_val'})
    expect { subject }.to raise_error(Puppet::Error,
                                      /"invalid_val" is not an absolute path\./)
  end

  it { is_expected.to contain_exec('test_git_config-testsection-testvariable-testvalue') \
    .with(
      'command' => "git config -f /opt/test.config --add testsection.testvariable 'testvalue'",
      'onlyif'  => "[ `git config -f /opt/test.config --get-all testsection.testvariable | grep -c 'testvalue'` == \"0\" ]",
    ) \
    .with_notify('Class[Gerrit::Service]') }

  it 'should remove testsection.testvariable value if ensure if absent' do
    params.merge!({'ensure' => 'absent'})
    is_expected.to contain_exec('test_git_config-testsection-testvariable-testvalue') \
      .with(
        'command' => "git config -f /opt/test.config --unset testsection.testvariable 'testvalue'",
        'onlyif'  => "[ `git config -f /opt/test.config --get-all testsection.testvariable | grep -c 'testvalue'` == \"1\" ]",
      )
  end
end
