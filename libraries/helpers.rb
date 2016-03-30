$LOAD_PATH.unshift(
  *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
)

require 'nori'

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

    # Public: Pass through an action to a Chef resource to avoid CHEF-3694.
    #
    # rc - The run_context object from the calling method.
    # resource_obj - The new_resource object from the calling method.
    # chef_obj - The Chef resource/object we want to pass the action to.
    # action - The action (as a symbol) to be passed
    # props - Hash of properties to pass to the Chef resource.
    #
    # Examples
    #
    #   AlteryxServer::Helpers.passthrough_action(
    #     run_context,
    #     new_resource,
    #     'service[AlteryxService]',
    #     :configure_startup,
    #     startup_type: :manual
    #   ) { service 'AlteryxService' do
    #     supports restart: true
    #     action :nothing
    #   end }
    #   # => #<Chef::Provider::Service::Windows:0x00000000000000
    #          @new_resource="AlteryxService", @action=nil,
    #          @current_resource=nil,
    #          @run_context=#<Chef::RunContext:0x00000000000000...>,
    #          @converge_actions=nil, @recipe_name=nil, @cookbook_name=nil,
    #          @enabled=nil>
    #
    # Returns a Chef service resource
    def self.passthrough_action(rc, resource_obj, chef_obj, action, props = nil)
      obj = lookup_resource(rc, chef_obj, &Proc.new)
      if props
        props.each do |k, v|
          obj.method(k).call(v) if obj.respond_to? k
        end
      end
      obj.run_action(action)
      resource_obj.updated_by_last_action(true) if obj.updated_by_last_action?
    end

    # Public: Find and return an existing resource. If the resource is not
    # found, execute a given block to set it up.
    #
    # run_cntxt - The run_context object from the calling method.
    # resrc - The name of the Chef resource to look up.
    #
    # Examples
    #
    #   AlteryxServer::Helpers.lookup_resource(
    #     run_context,
    #     'service[AlteryxService]'
    #   ) { service 'AlteryxService' do
    #     supports restart: true
    #     action :nothing
    #   end }
    #   # => #<Chef::Provider::Service::Windows:0x00000000000000
    #          @new_resource="AlteryxService", @action=nil,
    #          @current_resource=nil,
    #          @run_context=#<Chef::RunContext:0x00000000000000...>,
    #          @converge_actions=nil, @recipe_name=nil, @cookbook_name=nil,
    #          @enabled=nil>
    #
    # Return the requested Chef resource if it is found. Otherwise, create it.
    def self.lookup_resource(run_cntxt, resrc)
      resource_coll = run_cntxt.resource_collection
      resource_coll.find(resrc)
    rescue
      yield
    end

    # Public: Convert an XML file to a Ruby Hash.
    #
    # xml_file - String representation of a file path.
    #
    # Examples
    #
    #   puts File.read('C:\\some\\file.xml')
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <SystemSettings>
    #      <Engine>
    #        <NumThreads>2</NumThreads>
    #        <SortJoinMemory>959</SortJoinMemory>
    #      </Engine>
    #   </SystemSettings>
    #   # => nil
    #
    #   AlteryxServer::Helpers.parse_rts('C:\\some\\file.xml')
    #   # => {:system_settings=> {
    #         :engine=>{:num_threads=>"2", :sort_join_memory=>"959"}}}
    #
    # Return the constructed hash under the :system_settings key.
    def self.parse_rts(xml_file)
      xml = File.read(xml_file)
      parser = Nori.new(convert_tags_to: ->(tag) { tag.snakecase.to_sym })
      parser.parse(xml)[:system_settings]
    end

    # Public: Remove unnecessary keys from a hash of RuntimeSettings properties.
    #
    # rts_props - A hash of RuntimeSettings key/value pairs.
    #
    # Examples
    #
    #   puts rts_props
    #   # => {:controller=>{:server_secret_encrypted=>"000000"},
    #         :engine=>{:num_threads=>"2", :sort_join_memory=>"959"}}
    #
    #   AlteryxServer::Helpers.trim_rts_settings(some_rts_props)
    #   # => {:controller=>{:server_secret_encrypted=>"000000"}}
    #
    # Return a hash of settings we assume are valid.
    def self.trim_rts_settings(rts_props)
      rts_props.each do |top, mid|
        next if mid.nil?
        mid.each do |k, _v|
          rts_props[top].delete(k) unless k.to_s.include?('encrypted')
        end
      end
      rts_props.delete_if { |_k, v| v.empty? }
    end
  end
end
