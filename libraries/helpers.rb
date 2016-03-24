# Module for alteryx-server Cookbook so that LWRPs stay clean
module AlteryxServer
  # Module for helper functions and classes withing alteryx-server Cookbook
  module Helpers
    def self.exe_glob(dir)
      exe = Dir.glob("#{dir}*.exe")[0]
      exe.gsub('/', '\\')
    end

    def self.server_source(resource)
      base_url = 'http://downloads.alteryx.com/Alteryx'
      sub_path = 'AlteryxServerInstallx64_'
      full_version = resource.version
      full_url = "#{base_url}#{full_version}/#{sub_path}#{full_version}.exe"
      resource.source ? resource.source : full_url
    end

    def self.server_base_version(resource)
      base_version = resource.version.match(/[0-9]+\.[0-9]+/).to_s
      "Alteryx #{base_version} x64"
    end
  end
end
