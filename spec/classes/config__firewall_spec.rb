require 'spec_helper'

describe 'gerrit::config::firewall', :type => :class do
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

  # with the 'assumed' relevant defaults fall through from a basic
  # include ::gerrit
  context 'with assumed default parameters' do
    let(:params) {
      {
        'manage_firewall' => true,
        'options'         => {},
      }
    }

    it { is_expected.to contain_firewall('050 gerrit webui access').with(
        'proto'   => 'tcp',
        'state'   => ['NEW'],
        'action'  => 'accept',
        'dport'   => ['8080'],
    ) }
    it { is_expected.to contain_firewall('050 gerrit ssh access').with(
        'proto'   => 'tcp',
        'state'   => ['NEW'],
        'action'  => 'accept',
        'dport'   => ['29418'],
    ) }
  end

  context 'when not managing firewall' do
    let(:params) {
      {
        'manage_firewall' => false,
        'options'         => {},
      }
    }

      it { is_expected.to_not contain_firewall('050 gerrit webui access') }
      it { is_expected.to_not contain_firewall('050 gerrit ssh access') }
  end

  context 'firewall with alternative addresses and ports' do
    let(:params) {
      {
        'manage_firewall'   => true,
        'options'           => {
          'httpd'           => {
            'listenUrl'     => 'http://10.0.0.1:8082/',
          },
          'sshd'            => {
            'listenAddress' => '10.0.0.1:23000',
          },
        },
      }
    }

    it { is_expected.to contain_firewall('050 gerrit webui access').with(
        'proto'       => 'tcp',
        'state'       => ['NEW'],
        'action'      => 'accept',
        'destination' => '10.0.0.1',
        'dport'       => ['8082'],
    ) }
    it { is_expected.to contain_firewall('050 gerrit ssh access').with(
        'proto'       => 'tcp',
        'state'       => ['NEW'],
        'action'      => 'accept',
        'destination' => '10.0.0.1',
        'dport'       => ['23000'],
    ) }
  end
end

# vim: sw=2 ts=2 sts=2 et :
