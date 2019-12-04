require 'spec_helper'

describe 'gerrit::service', :type => :class do
  # set some default good params so we can override with bad ones in
  # test
  let(:params) {
    {
      'service_enabled' => true,
    }
  }

  # we do not have default values so the class should fail to compile
  context 'with defaults for all parameters' do
    let (:params) {{}}

    it do
      expect {
        should compile
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
        /service_enabled/)
    end
  end

  # with assumed good params
  context 'with good parameters' do
    it { is_expected.to contain_service('gerrit').with(
        :ensure   => true,
        :enable   => true,
      ) }
  end

  context 'service_enabled is incorrect' do
    let(:params) {{ 'service_enabled' => 'invalid_val' }}

    it 'should report an error when service_enabled is invalid' do
      expect { should compile }.to \
        raise_error(RSpec::Expectations::ExpectationNotMetError,
          /invalid_val is not supported for service_enabled\. \
Allowed values are true, false, 'manual'\./)
    end
  end

  context 'service_enabled set to false' do
    let(:params) {{ 'service_enabled' => false }}

    it { is_expected.to contain_service('gerrit').with(
        :ensure => false
      ) }
  end

  context 'service_enabled set to manual' do
    let(:params) {{ 'service_enabled' => 'manual' }}

    it { is_expected.to contain_service('gerrit').with(
        :enable => 'manual',
      ) }
  end
end

# vim: sw=2 ts=2 sts=2 et :
