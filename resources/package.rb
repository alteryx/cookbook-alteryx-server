property :source, String
property :version, String
property :options, String
property :timeout, [String, Fixnum]

default_action :install

def package_name
  script = 'powershell "(Get-ItemProperty HKLM:\\\\Software\\\\Microsoft\\\\'\
    'Windows\\\\CurrentVersion\\\\Uninstall\\\\* |  Select-Object DisplayName,'\
    'Publisher |  Where-Object {$_.Publisher -like \'Alteryx\'}).DisplayName'
  package_name = shell_out(script).stdout.strip
  package_name.empty? ? 'Alteryx' : package_name
end

load_current_value do
  version node['alteryx']['version'] unless version

  source node['alteryx']['source'] if node['alteryx']['source'] && source.nil?
  source AlteryxServer::Helpers.server_link(version) unless source
  timeout node['alteryx']['installer_timeout'] unless timeout
  options '/s' unless options
end

action :install do
  pkg_name = package_name
  pkg_source = source
  pkg_version = version
  pkg_timeout = timeout
  pkg_options = options

  # Allow custom options but make sure the silent flag is in the options list
  unless pkg_options =~ /\/s/
    pkg_options =+ ' /s'
  end

  package pkg_name do
    source pkg_source
    options pkg_options
    version pkg_version
    timeout pkg_timeout
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
