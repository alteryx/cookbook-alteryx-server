module AlteryxServer
  # Chef provider for installing Alteryx server
  class ServerInstallProvider < Chef::Provider::LWRPBase
    provides :alteryx_install if respond_to?(:provides)

    def initialize(name, run_context = nil)
      super
      @helpers = AlteryxServer::Helpers

      set_version
      @ayx_package = @helpers.package_name(new_resource.version)
      set_source
    end

    def set_version
      version_default = node['alteryx']['version']
      new_resource.version(version_default) unless new_resource.version
    end

    def set_source
      if node['alteryx']['source'] && new_resource.source.nil?
        return new_resource.source(node['alteryx']['source'])
      end
      set_link unless new_resource.source
    end

    def set_link
      source_default = @helpers.server_link(new_resource.version)
      new_resource.source(source_default)
    end

    action :install do
      package @ayx_package do
        source new_resource.source
        options '/s'
        version new_resource.version
        action :install
      end
    end
  end
end
