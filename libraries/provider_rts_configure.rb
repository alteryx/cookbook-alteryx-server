module AlteryxServer
  # Chef provider for configuring RuntimeSettings.xml overrides
  class RtsProvider < Chef::Provider::LWRPBase
    include AlteryxServer::Helpers
    provides :runtimesettings_configure

    action :manage do
      template node['alteryx']['rts_path'] do
        source 'RuntimeSettings.xml.erb'
        variables config: new_resource.config
      end
    end
  end
end
