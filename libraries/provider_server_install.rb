module AlteryxServer
  # Chef provider for installing Alteryx server
  class ServerInstallProvider < Chef::Provider::LWRPBase
    provides :alteryx_install if respond_to?(:provides)

    action :install do
      package AlteryxServer::Helpers.server_base_version(new_resource) do
        source AlteryxServer::Helpers.server_source(new_resource)
        options '/s'
        version new_resource.version
        action :install
      end
    end
  end
end
