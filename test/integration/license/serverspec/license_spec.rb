require 'spec_helper'

describe service('AlteryxService') do
  it { should be_running }
  it { should have_start_mode('Automatic') }
end
