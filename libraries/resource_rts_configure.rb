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

    attribute(
      :restart_on_change,
      kind_of: [TrueClass, FalseClass],
      default: lazy { node['alteryx']['restart_on_config_change'] }
    )

    attribute(
      :secrets,
      kind_of: Hash,
      default: {}
    )

    attribute(
      :force_secrets_update,
      kind_of: [TrueClass, FalseClass],
      default: lazy { node['alteryx']['force_secrets_update'] }
    )
  end
end
