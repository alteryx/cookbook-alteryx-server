property :source, [String, nil], default: nil
property :version, [String, nil], default: nil
property :timeout, [String, Fixnum]

default_action :install

def local_r_version
  script = <<-EOF
    powershell "(get-item '#{source}').VersionInfo.FileVersion"
  EOF

  shell_out(script).stdout.strip
end

# R Development Core Team
def package_name
  script = 'powershell "(Get-ItemProperty HKLM:\\\\Software\\\\Microsoft\\\\'\
    'Windows\\\\CurrentVersion\\\\Uninstall\\\\* |  Select-Object DisplayName,'\
    'Publisher |  Where-Object {$_.Publisher -like '\
    '\'R Development Core Team\'}).DisplayName'
  package_name = shell_out(script).stdout.strip
  package_name.empty? ? 'AlteryxRTools' : package_name
end

load_current_value do
  r_source_attr = node['alteryx']['r_source']
  helpers = AlteryxServer::Helpers

  source r_source_attr if r_source_attr && source.nil?
  source helpers.exe_glob(helpers::R_DIR) unless source

  version node['alteryx']['r_version'] unless version
  version local_r_version unless version
  timeout node['alteryx']['r_installer_timeout'] unless timeout
end

action :install do
  pkg_name = package_name
  pkg_source = source
  pkg_timeout = timeout

  windows_package pkg_name do
    source pkg_source
    installer_type :custom
    options '/s'
    timeout pkg_timeout
    action :install
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
