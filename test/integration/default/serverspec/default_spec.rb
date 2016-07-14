require 'spec_helper'

describe package('Alteryx 10.6 x64') do
  it { should be_installed.with_version('10.6.8.17850') }
end

describe package('Alteryx Predictive Tools with R 3.2.3') do
  it { should be_installed.with_version('3.2.3') }
end

describe service('AlteryxService') do
  it { should be_installed }
  it { should be_enabled }
end

describe file('C:\\ProgramData\\Alteryx\\RuntimeSettings.xml') do
  # We can't reliably test the contents of RuntimeSettings.xml since encrypted
  # values are always unique.
  #
  # We'll let the unit tests take care of verifying the defaults.
  it { should be_file }
end
