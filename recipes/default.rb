#
# Cookbook Name:: alteryx-server
# Recipe:: default
#

# see README.md for more examples
alteryx_server_package 'Alteryx Server'

alteryx_server_r_package 'R Predictive Tools'

alteryx_server_service 'AlteryxService'

alteryx_server_runtimesettings 'RuntimeSettings.xml'
