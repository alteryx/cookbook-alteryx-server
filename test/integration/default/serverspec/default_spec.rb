require 'spec_helper'

describe package('Alteryx 10.1 x64') do
  it { should be_installed.with_version('10.1.7.12188') }
end

describe package('Alteryx Predictive Tools with R 3.2.3') do
  it { should be_installed.with_version('3.2.3') }
end

describe service('AlteryxService') do
  it { should be_installed }
  it { should be_enabled }
end

describe file('C:\\ProgramData\\Alteryx\\RuntimeSettings.xml') do
  content = <<-EOH.gsub(/^ +/, '')
    <?xml version="1.0" encoding="UTF-8"?>
    <SystemSettings>
    \t<Engine>
    \t\t<NumThreads>2</NumThreads>
    \t\t<SortJoinMemory>959</SortJoinMemory>
    \t</Engine>
    </SystemSettings>
  EOH
  it { should be_file }
  its(:content) { should match content }
end
