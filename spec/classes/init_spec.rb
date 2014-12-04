require 'spec_helper'
describe 'gerrit' do

  context 'with defaults for all parameters' do
    it { should contain_class('gerrit') }
  end
end
