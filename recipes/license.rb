#
# Cookbook Name:: alteryx-server
# Recipe:: license
#

# see README.md for more examples
alteryx_server_license node['alteryx']['license']['key']

alteryx_server_service 'AlteryxService' do
  action :start
end
