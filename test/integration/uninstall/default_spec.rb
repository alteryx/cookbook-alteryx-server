describe package('Alteryx 11.0 x64') do
  it { should_not be_installed }
end

describe package('Alteryx Predictive Tools with R 3.3.2') do
  it { should_not be_installed }
end
