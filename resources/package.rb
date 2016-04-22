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
    action :install
  end
end
