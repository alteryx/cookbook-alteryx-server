# Module for alteryx-server Cookbook so that LWRPs stay clean
module AlteryxServer
  # Module for helper functions and classes withing alteryx-server Cookbook
  module Helpers
    # Public: Find the first exe alphabetically in a directory.
    # Useful for finding the R installer.
    #
    # dir - The directory in which to look for .exe files.
    #
    # Examples
    #
    #   AlteryxServer::Helpers.exe_glob(
    #     'C:\\Program Files\\Alteryx\\RInstaller'
    #   )
    #   # => 'C:\\Program Files\\Alteryx\\RInstaller\\'
    #        'RInstaller_10.1.7.11834.exe'
    #
    # Returns the file path of the first alphabetical exe in a given directory.
    def self.exe_glob(dir)
      exe = Dir.glob("#{dir}*.exe")[0]
      exe.gsub('/', '\\')
    end

    # Public: Construct download url or use source specified in LWRP call.
    #
    # resource - The 'new_resource' object created in an action of the
    #            LWRP provider.
    #
    # Examples
    #
    #   AlteryxServer::Helpers.server_source(new_resource)
    #   # => 'http://downloads.alteryx.com/Alteryx10.1.7.11834/'\
    #        'AlteryxServerInstallx64_10.1.7.11834.exe'
    #
    # Returns either the new_resource.source property or the constructed URL.
    def self.server_source(resource)
      base_url = 'http://downloads.alteryx.com/Alteryx'
      sub_path = 'AlteryxServerInstallx64_'
      full_version = resource.version
      full_url = "#{base_url}#{full_version}/#{sub_path}#{full_version}.exe"
      resource.source ? resource.source : full_url
    end

    # Public: Get the base server version from a version string.
    #
    # resource - The 'new_resource' object created in an action of the
    #            LWRP provider.
    #
    # Examples
    #
    #   # new_resource.version = '10.1.7.11834'
    #   AlteryxServer::Helpers.base_version(new_resource)
    #   # => '10.1'
    #
    # Return the major/minor version from a full version string.
    def self.server_base_version(resource)
      base_version = resource.version.match(/[0-9]+\.[0-9]+/).to_s
      "Alteryx #{base_version} x64"
    end

    # Public: Convert 'some_word' to 'SomeWord'.
    #         Useful for transforming RTS node attributes to RTS XML properties.
    #
    # name - A string in the format of 'some_string'.
    # close - Boolean that is true if this will be a closing tag.
    #
    # Examples
    #
    #   AlteryxServer::Helpers.rts_tag('some_string', true)
    #   # => '</SomeString>'
    #
    #   AlteryxServer::Helpers.rts_tag('someother_string', false)
    #   # => '<SomeotherString>'
    #
    # Returns a properly cased and formatted XML tag.
    def self.rts_tag(name, close)
      tag = close ? '/' : ''
      setting = name.to_s.capitalize
      setting.gsub!(/_[a-z0-9]+/) do |match|
        match.gsub!(/_/, '')
        %w(db url).include?(match) ? match.upcase : match.capitalize
      end
      "<#{tag}#{setting}>"
    end

    # Public: Format RTS property value correctly. For example, capitalize
    # true/false boolean conversions to strings.
    #
    # value - A value to format.
    #
    # Examples
    #
    #  AlteryxServer::Helpers.rts_value(false)
    #  # => 'False'
    #
    # Returns a formatted string
    def self.rts_value(value)
      [true, false].include?(value) ? value.to_s.capitalize : value.to_s
    end
  end
end
