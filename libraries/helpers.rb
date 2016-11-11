# Load vendored gems and make them available during compile time.
$LOAD_PATH.unshift(
  *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
)

require 'nori'

# Module for alteryx-server Cookbook so that LWRPs stay clean
module AlteryxServer
  # Module for helper functions and classes withing alteryx-server Cookbook
  module Helpers
    # Declare some constants and make them immutable.
    SVC_EXE = 'C:\\Program Files\\Alteryx\\bin\\AlteryxService.exe'.freeze
    R_DIR = 'C:/Program Files/Alteryx/RInstaller/'.freeze
    CONVERSIONS = Mash.from_hash(
      execute_user: {
        worker: 'execute_password_encrypted'
      },
      mongo_password: {
        controller: 'mongo_db_password_encrypted'
      },
      remote_secret: {
        worker: 'server_secret_encrypted'
      },
      server_secret: {
        controller: 'server_secret_encrypted'
      },
      smtp_password: {
        gallery: 'smtp_password_encrypted'
      }
    ).freeze

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
      exe.tr('/', '\\') if exe
    end

    # Public: Construct download url or use source specified in LWRP call.
    #
    # version - Full version string.
    #
    # Examples
    #
    #   AlteryxServer::Helpers.server_link('10.1.7.11834')
    #   # => 'http://downloads.alteryx.com/Alteryx10.1.7.11834/'\
    #        'AlteryxServerInstallx64_10.1.7.11834.exe'
    #
    # Returns either the new_resource.source property or the constructed URL.
    def self.server_link(version)
      base_url = 'http://downloads.alteryx.com/Alteryx'
      sub_path = 'AlteryxServerInstallx64_'
      "#{base_url}#{version}/#{sub_path}#{version}.exe"
    end

    # Public: Construct the package name for server installs.
    #
    # version - A full version string.
    #
    # Examples
    #
    #   AlteryxServer::Helpers.package_name('10.1.7.11834')
    #   # => 'Alteryx 10.1 x64'
    #
    # Return the major/minor version from a full version string.
    def self.package_name(version)
      base_version = version.match(/[0-9]+\.[0-9]+/).to_s
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
      s = name.to_s.dup
      s.gsub!(/[a-z0-9]+/) do |match|
        c = %w(db url ipv6 sql).include?(match) && !s.include?('elastic_search')
        c ? match.upcase : match.capitalize
      end
      s.delete!('_')
      "<#{tag}#{s}>"
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
    #  AlteryxServer::Helpers.rts_value(true)
    #  # => 'True'
    #
    #  AlteryxServer::Helpers.rts_value('some value')
    #  # => 'some value'
    #
    # Returns a formatted string
    def self.rts_value(value)
      [true, false].include?(value) ? value.to_s.capitalize : value.to_s
    end

    # Public: Pass through an action to a Chef resource to avoid CHEF-3694.
    #
    # rc - The run_context object from the calling method.
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
    # Returns a Chef resource
    def self.passthrough_action(rc, chef_obj, action, props = nil)
      obj = lookup_resource(rc, chef_obj, &Proc.new)
      if props
        props.each do |k, v|
          obj.method(k).call(v) if obj.respond_to? k
        end
      end
      obj.run_action(action)
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

    # Public: Convert an XML file to a Ruby Mash.
    #
    # xml_file - String representation of a file path.
    # trim - Whether to trim extra settings or not.
    #
    # Examples
    #
    #   puts File.read('C:\\some\\file.xml')
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <SystemSettings>
    #      <Controller>
    #        <ServerSecretEncrypted>20000</ServerSecretEncrypted>
    #      </Controller>
    #      <Engine>
    #        <NumThreads>2</NumThreads>
    #        <SortJoinMemory>959</SortJoinMemory>
    #      </Engine>
    #   </SystemSettings>
    #   # => nil
    #
    #   AlteryxServer::Helpers.parse_rts('C:\\some\\file.xml')
    #   # => {:engine=>{:num_threads=>"2", :sort_join_memory=>"959"
    #         :controller=>{:server_secret_encrypted=>"20000"}}}
    #
    #   AlteryxServer::Helpers.parse_rts('C:\\some\\file.xml', true)
    #   # => {:controller=>{:server_secret_encrypted=>"20000"}}}
    #
    # Return the constructed Mash under the :system_settings key,
    # dropping settings if told.
    def self.parse_rts(xml_file, trim = false)
      xml = File.read(xml_file)
      parser = Nori.new(convert_tags_to: ->(tag) { tag.snakecase.to_sym })
      hash = parser.parse(xml)[:system_settings]
      hash = trim_rts_settings(hash) if trim
      Mash.from_hash(hash)
    end

    # Public: Find and preserve keys/secrets that are encrypted from
    # the RuntimeSettings.xml overrides.
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
          next if k.to_s.include?('encrypted')
          rts_props[top].delete(k)
        end
      end
      delete_empty(rts_props)
    end

    # Public: Delete empty top-level elements from Hash or Mash.
    #
    # store - A Hash or Mash.
    #
    # Examples
    #
    #   puts store
    #   # => {:controller=>{:server_secret_encrypted=>"000000"},
    #         :engine=>{}}
    #
    #   AlteryxServer::Helpers.delete_empty(store)
    #   # => {:controller=>{:server_secret_encrypted=>"000000"}
    #
    # Return a Hash or Mash with empty top-level keys removed.
    def self.delete_empty(store)
      store.delete_if { |_k, v| v.empty? }
    end

    # Public: Check if all desired secrets are encrypted in RTS.
    #
    # current - A Mash of current settings in RTS.
    # new - A Mash of secrets to be encrypted.
    #
    # Examples
    #
    #   puts current
    #   # => {"controller"=>{"mongo_db_password_encrypted"=>"000000"}}
    #
    #   puts new
    #   # => {"mongo_password" => "somepass"}
    #
    #   AlteryxServer::Helpers.secrets_unencrypted?(current, new)
    #   # => false
    #
    #   ----------------
    #
    #   puts current
    #   # => {"controller"=>{}}
    #
    #   puts new
    #   # => {"mongo_password" => "somepass"}
    #
    #   AlteryxServer::Helpers.secrets_unencrypted?(current, new)
    #   # => true
    #
    # Return true if there secrets that need to be encrypted, false otherwise.
    def self.secrets_unencrypted?(current, new)
      new.each do |new_k, _new_v|
        key_pair = CONVERSIONS[new_k]
        k = key_pair.keys.first
        v = key_pair.values.first
        return true if current[k].nil? || current[k][v].nil?
      end
      false
    end
  end
end
