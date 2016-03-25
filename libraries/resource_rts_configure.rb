module AlteryxServer
  # Chef resource for configuring RuntimeSettings.xml overrides
  class RtsResource < Chef::Resource::LWRPBase
    resource_name :runtimesettings_configure
    provides :runtimesettings_configure

    actions(:manage)
    default_action :manage

    attribute(
      :config,
      kind_of: Hash,
      default: lazy { node['alteryx']['runtimesettings'] }
    )
  end
end
