require 'spec_helper'

describe 'gerrit::install::third_party_plugin', :type => :define do
  let(:title) { 'testplugin' }
  let(:params) {
    {
      'gerrit_home' => '/opt/foo',
      'gerrit_user' => 'foo',
    }
  }

  [
    'file:///foo_plugin',
    'puppet:///modules/foo/foo_plugin'
  ].each do |plug_source|
    it "should handle #{plug_source} for a source" do
      params.merge!({'plugin_source' => plug_source})

      is_expected.to contain_file('testplugin').with(
        'ensure' => 'file',
        'path'   => "#{params['gerrit_home']}/plugins/#{title}.jar",
        'source' => plug_source,
        'owner'  => params['gerrit_user'],
        'group'  => params['gerrit_user'],
      )
    end
  end

  [
    'http://plug.forge/foo.jar',
    'https://plug.forge/foo.jar'
  ].each do |plug_source|
    it "should handle #{plug_source} for a source" do
      params.merge!({'plugin_source' => plug_source})

      is_expected.to contain_file("#{params['gerrit_home']}/plugin_cache").with(
        'ensure' => 'absent',
        'purge'  => true,
        'force'  => true,
      )

      is_expected.to contain_wget__fetch("download #{title} gerrit plugin").with(
        'source'      => plug_source,
        'destination' => "#{params['gerrit_home']}/plugins/#{title}.jar",
        'flags'       => ['--timestamping'],
        'timeout'     => 0,
        'verbose'     => false,
        'cache_dir'   => nil,
        'require'     => nil,
      )
    end
  end
end

# vim: sw=2 ts=2 sts=2 et :
