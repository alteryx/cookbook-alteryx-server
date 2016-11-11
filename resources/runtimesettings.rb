property :config, Hash
property :restart_on_change, [TrueClass, FalseClass]
property :secrets, Hash, default: {}
property :force_secrets_update, [TrueClass, FalseClass]

default_action :manage

action :manage do
  # Declare helpers to help shorten our calls to the module methods.
  helpers = AlteryxServer::Helpers
  defaults_path = node['alteryx']['rts_defaults_path']
  overrides_path = node['alteryx']['rts_overrides_path']
  restart_svc = node['alteryx']['restart_on_change']
  unless new_resource.restart_on_change.nil?
    restart_svc = new_resource.restart_on_change
  end
  service_resource = 'alteryx_server_service[AlteryxService]'

  # Initialize overrides variable. Store encrypted secrets/passwords
  # from RTS overrides file into a Mash.
  overrides = helpers.parse_rts(overrides_path, true)

  # Get default RTS settings and store in a Mash.
  defaults = helpers.parse_rts(defaults_path)

  # If we have both node attributes and parameters from the config attribute
  # we'll merge them together.
  rts_defaults = {}
  rts_defaults.merge!(node['alteryx']['runtimesettings'])
  if rts_defaults && new_resource.config
    keys = (rts_defaults.keys + new_resource.config.keys).uniq
    keys.each do |key|
      if rts_defaults.key?(key) && new_resource.config.key?(key)
        rts_defaults[key].merge!(new_resource.config[key])
      elsif !rts_defaults.key?(key) && new_resource.config.key?(key)
        rts_defaults[key] = new_resource.config[key]
      end
    end
  end
  new_resource.config(rts_defaults) if rts_defaults

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
      default = (d == 'True' || d == 'False') ? d.downcase : d
      v.to_s == default
    end
  end

  # Delete any top-level keys if they are empty.
  # We don't want something like '<Engine></Engine>' in RuntimeSettings.
  overrides = helpers.delete_empty(overrides)

  # Render the template using the overrides variable.
  template overrides_path do
    source 'RuntimeSettings.xml.erb'
    variables config: overrides
    notifies :restart, service_resource, :delayed if restart_svc
    cookbook 'alteryx-server'
  end

  # Generate secrets if:
  #  - Secrets have been passed.
  #  - We are missing at least one desired encrypted secret.
  #  - The user has told us to force an update of encrypted secrets.
  #
  # Also, restart the service if the attribute to do so is set.
  ruby_block 'Generate secrets' do
    block do
      new_resource.secrets.each do |k, v|
        setting = "set#{k.to_s.delete('_')}"
        value = if k.to_s == 'execute_user'
                  "#{v[:user]},#{v[:domain]},#{v[:password]}"
                else
                  v
                end
        shell_out("\"#{helpers::SVC_EXE}\" #{setting}=\"#{value}\"")
      end
    end
    notifies :restart, service_resource, :delayed if restart_svc
    only_if do
      (new_resource.secrets &&
       helpers.secrets_unencrypted?(overrides, new_resource.secrets)
      ) || new_resource.force_secrets_update
    end
  end
end
