property :source, [String, nil], default: nil
property :version, [String, nil], default: nil

default_action :install

def local_r_version
  script = <<-EOF
    powershell "(get-item '#{source}').VersionInfo.FileVersion"
  EOF

  shell_out(script).stdout.strip
end

load_current_value do
  r_source_attr = node['alteryx']['r_source']
  helpers = AlteryxServer::Helpers

  source r_source_attr if r_source_attr && source.nil?
  source helpers.exe_glob(helpers::R_DIR) unless source

  version node['alteryx']['r_version'] unless version
  version local_r_version unless version
end

action :install do
  pkg_name = "Alteryx Predictive Tools with R #{version}"
  pkg_source = source

  # for chef-client 13 and later, use the Chef package resource
  # for chef-client earlier than 13, use the Chef windows_package resource

  # find the chef-client version
  chef_client_version = node['chef_packages']['chef']['version']
  # run the appropriate resource
  if chef_client_version < '13'
    windows_package pkg_name do
      source pkg_source
      installer_type :custom
      options '/s'
      action :install
    end
  else
    package pkg_name do
      source pkg_source
      options '/s'
      action :install
    end
  end
end

action :uninstall do
  powershell_script 'Uninstall Predictive Tools with R' do
    code
    <<-EOH
      $product = gwmi win32_product -filter "Name LIKE 'Alteryx Predictive Tools with R %'"
      if ( $product ){
        $cmd = 'C:\\ProgramData\\{0}\\RInstaller.exe' -f $product.PackageCode
        & $cmd /s REMOVE=TRUE MODIFY=FALSE
      }
      EOH
  end
end
