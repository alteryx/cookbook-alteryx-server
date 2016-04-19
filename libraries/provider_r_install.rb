module AlteryxServer
  # Chef provider for installing R Predictive Tools
  class RInstallProvider < Chef::Provider::LWRPBase
    provides :r_install

    def initialize(name, run_context = nil)
      super
      @helpers = AlteryxServer::Helpers

      set_source
      set_version
    end

    def set_source
      src_default = node['alteryx']['r_source']
      new_resource.source(src_default) unless new_resource.source
      return if new_resource.source
      new_resource.source(@helpers.exe_glob(@helpers::R_DIR))
    end

    def set_version
      version_default = node['alteryx']['r_version']
      new_resource.version(version_default) unless new_resource.version
      return if new_resource.version
      process_bundled
    end

    def process_bundled
      script = <<-EOF
        powershell "(get-item '#{new_resource.source}').VersionInfo.FileVersion"
      EOF
      new_resource.version(shell_out(script).stdout.strip)
    end

    action :install do
      pkg_name = "Alteryx Predictive Tools with R #{new_resource.version}"
      windows_package pkg_name do
        source new_resource.source
        installer_type :custom
        options '/s'
        action :install
      end
    end
  end
end
