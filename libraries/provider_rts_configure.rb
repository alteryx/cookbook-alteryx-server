module AlteryxServer
  # Chef provider for configuring RuntimeSettings.xml overrides
  class RtsProvider < Chef::Provider::LWRPBase
    provides :runtimesettings_configure

    action :manage do
      # Declare helpers to help shorten our calls to the module methods.
      helpers = AlteryxServer::Helpers

      # Initialize overrides variable. Store encrypted secrets/passwords
      # from RTS overrides file and in said variable and convert to a Mash.
      overrides = helpers.parse_rts(node['alteryx']['rts_overrides_path'])
      overrides = helpers.trim_rts_settings(overrides)
      overrides = Mash.from_hash(overrides)

      # Get default RTS settings and store in a Mash.
      defaults = helpers.parse_rts(node['alteryx']['rts_defaults_path'])
      defaults = Mash.from_hash(defaults)

      # Merge user-supplied override settings onto stored
      # secret/passwords Mash.
      new_resource.config.each do |top, mid|
        overrides[top] ||= {}
        overrides[top].merge!(mid)
      end

      # Loop over the default settings and delete any keys in overrides
      # if they match the default value.
      # We're converting everything to a string for easier comparison.
      defaults.each do |top, _mid|
        next unless overrides[top]
        overrides[top].delete_if do |k, v|
          d = defaults[top][k].to_s
          default = d == 'True' || d == 'False' ? d.downcase : d
          v.to_s == default
        end
      end

      # Delete any top-level keys if they are empty.
      # We don't want something like '<Engine></Engine>' in RuntimeSettings.
      overrides = helpers.delete_empty(overrides)

      # Render the template using the overrides variable.
      template node['alteryx']['rts_overrides_path'] do
        source 'RuntimeSettings.xml.erb'
        variables config: overrides
        if new_resource.restart_on_change
          notifies :restart, 'service[AlteryxService]', :delayed
        end
      end
    end
  end
end
