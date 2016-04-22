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

  windows_package pkg_name do
    source pkg_source
    installer_type :custom
    options '/s'
    action :install
  end
end
