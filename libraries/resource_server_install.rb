module AlteryxServer
  # Chef resource for installing Alteryx
  class ServerInstallResource < Chef::Resource::LWRPBase
    resource_name :alteryx_install if respond_to?(:resource_name)
    provides :alteryx_install

    actions(:install)
    default_action :install

    attribute(
      :source,
      kind_of: String
    )
    attribute(
      :version,
      kind_of: String
    )
  end
end
