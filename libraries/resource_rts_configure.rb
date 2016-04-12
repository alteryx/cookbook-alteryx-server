module AlteryxServer
  # Chef resource for configuring RuntimeSettings.xml overrides
  class RtsResource < Chef::Resource::LWRPBase
    resource_name :runtimesettings_configure
    provides :runtimesettings_configure

    actions(:manage)
    default_action :manage

    attribute(
      :config,
      kind_of: Hash
    )

    attribute(
      :restart_on_change,
      kind_of: [TrueClass, FalseClass]
    )

    attribute(
      :secrets,
      kind_of: Hash,
      default: {}
    )

    attribute(
      :force_secrets_update,
      kind_of: [TrueClass, FalseClass]
    )
  end
end
