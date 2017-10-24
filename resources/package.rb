property :source, String
property :version, String

default_action :install

load_current_value do
  version node['alteryx']['version'] unless version

  source node['alteryx']['source'] if node['alteryx']['source'] && source.nil?
  source AlteryxServer::Helpers.server_link(version) unless source
end

action :install do
  package_name = AlteryxServer::Helpers.package_name(version)
  pkg_source = source
  pkg_version = version

  package package_name do
    source pkg_source
    options '/s'
    version pkg_version
    timeout node['alteryx']['install_timeout']
    action :install
  end
end

action :uninstall do
  powershell_script 'Uninstall Alteryx' do
    code <<-EOH
      $product = gwmi win32_product -filter "Name LIKE 'Alteryx % x64'"
      if ( $product ){
        $cmd = 'C:\\ProgramData\\{0}\\AlteryxInstallx64.exe' -f $product.PackageCode
        & $cmd /s REMOVE=TRUE MODIFY=FALSE
      }
      EOH
  end
end
