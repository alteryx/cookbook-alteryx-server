module AlteryxServer
  # Chef provider for installing R Predictive Tools
  class RInstallProvider < Chef::Provider::LWRPBase
    provides :r_install

    action :install do
      if new_resource.source
        pkg_source = new_resource.source
      else
        glob_loc = 'C:/Program Files/Alteryx/RInstaller/'
        pkg_source = AlteryxServer::Helpers.exe_glob(glob_loc)
      end

      if new_resource.version
        r_version = new_resource.version
      else
        script = <<-EOF
          powershell "(get-item '#{pkg_source}').VersionInfo.FileVersion"
        EOF
        r_version = shell_out(script).stdout.strip
      end

      windows_package "Alteryx Predictive Tools with R #{r_version}" do
        source pkg_source
        installer_type :custom
        options '/s'
        action :install
      end
    end
  end
end
