module AlteryxServer
  # Chef provider for installing R Predictive Tools
  class RInstallProvider < Chef::Provider::LWRPBase
    provides :r_install

    action :install do
      package_source = new_resource.source

      if new_resource.version
        r_version = new_resource.version
      else
        script = <<-EOF
          powershell "(get-item '#{package_source}').VersionInfo.FileVersion"
        EOF
        r_version = shell_out(script).stdout.strip
      end

      windows_package "Alteryx Predictive Tools with R #{r_version}" do
        source package_source
        installer_type :custom
        options '/s'
        action :install
      end
    end
  end
end
