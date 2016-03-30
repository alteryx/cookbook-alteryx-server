#
# Cookbook Name:: cookbook-alteryx-server
# Recipe:: default
#

# see README.md for more examples
alteryx_install 'Alteryx Server'

r_install 'R Predictive Tools'

runtimesettings_configure 'RuntimeSettings.xml'

alteryx_service 'AlteryxService'
