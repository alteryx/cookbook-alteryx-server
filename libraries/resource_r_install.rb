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
      default: lazy do
        AlteryxServer::Helpers.exe_glob('C:/Program Files/Alteryx/RInstaller/')
      end
    )

    attribute(
      :version,
      kind_of: String,
      default: nil
    )
  end
end
