class Chef
  class Resource
    # Chef resource for installing Alteryx
    class AlteryxServerInstall < Chef::Resource::LWRPBase
      resource_name :alteryx_install if respond_to?(:resource_name)
      provides :alteryx_install

      actions(:install)
      default_action :install

      attribute(:source, kind_of: String, default: nil)
    end
  end
end
