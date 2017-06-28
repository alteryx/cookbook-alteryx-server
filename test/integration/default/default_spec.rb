describe package('Alteryx 11.3 x64') do
  it { should be_installed }
  its('version') { should eq '11.3.2.29874' }
end

describe package('Alteryx Predictive Tools with R 3.3.2') do
  it { should be_installed }
  its('version') { should eq '3.3.2' }
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
