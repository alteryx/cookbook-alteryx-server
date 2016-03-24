module AlteryxServer
  # Chef resource for installing Alteryx
  class ServerInstallResource < Chef::Resource::LWRPBase
    resource_name :alteryx_install if respond_to?(:resource_name)
    provides :alteryx_install

    actions(:install)
    default_action :install

    attribute(:source, kind_of: String, default: nil)
    attribute(:version, kind_of: String, default: '10.1.7.12188')
  end
end
