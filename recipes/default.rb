#
# Cookbook Name:: cookbook-alteryx-server
# Recipe:: default
#

# see README.md for more examples
alteryx_install 'Alteryx Server' do
  source 'http://downloads.alteryx.com/Alteryx10.1.7.12188/AlteryxServerInstallx64_10.1.7.12188.exe'
end
