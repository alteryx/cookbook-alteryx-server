module AlteryxServer
  # Chef provider for installing R Predictive Tools
  class RInstallProvider < Chef::Provider::LWRPBase
    provides :r_install

    action :install do
      windows_package 'Alteryx Predictive Tools with R 3.2.3' do
        source new_resource.source
        installer_type :custom
        options '/s'
        action :install
      end
    end
  end
end
