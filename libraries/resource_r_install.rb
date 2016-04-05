module AlteryxServer
  # Chef resource for installing R Predictive tools
  class RInstallResource < Chef::Resource::LWRPBase
    resource_name :r_install
    provides :r_install

    actions(:install)
    default_action :install

    attribute(
      :source,
      kind_of: String,
      default: lazy { node['alteryx']['r_source'] }
    )

    attribute(
      :version,
      kind_of: String,
      default: lazy { node['alteryx']['r_version'] }
    )
  end
end
