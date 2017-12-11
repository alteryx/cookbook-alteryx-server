default['alteryx'] = {}
default['alteryx']['installer_timeout'] = 3600
default['alteryx']['r_installer_timeout'] =
  default['alteryx']['installer_timeout']
default['alteryx']['license'] = {}
default['alteryx']['force_secrets_update'] = nil
default['alteryx']['r_source'] = nil
default['alteryx']['r_version'] = nil
default['alteryx']['restart_on_change'] = false
default['alteryx']['source'] = nil
default['alteryx']['version'] = '11.7.4.37815'
default['alteryx']['runtimesettings']['engine']['num_threads'] =
  node['cpu']['total'] + 1
default['alteryx']['runtimesettings']['engine']['sort_join_memory'] =
  (node['kernel']['os_info']['total_visible_memory_size'].to_i * 0.8 /
  1024 / (node['cpu']['total'] + 1)).to_i
default['alteryx']['rts_defaults_path'] =
  'C:\\Program Files\\Alteryx\\bin\\RuntimeData\\RuntimeSettings.xml'
default['alteryx']['rts_overrides_path'] =
  'C:\\ProgramData\\Alteryx\\RuntimeSettings.xml'
