alteryx-server Cookbook
================================
A Chef cookbook to install and configure Alteryx Server.

Requirements
------------
- `windows` - alteryx-server only supports the Windows platform.
- `chef-client >= 12.6.0` - alteryx-server only supports chef-client versions of 12.6.0 or above

Recipes
-------
Resources are the intended way to consume this cookbook, however we've provided a single recipe that installs and starts a standalone server.

### default

The default recipe downloads, installs, and configures Alteryx Server as well as Alteryx R Predictive Tools.

Resources
---------

### alteryx_install
Actions: `:install`

Installs Alteryx Server.

#### Attributes
|Name  |Type  |Default|Description|
|------|------|-------|-----------|
|source|String|`nil`  |**Optional**: Local path or URL (will download from alteryx.com with version if not specified)|
|version|String|`node['alteryx']['version'] = '10.1.7.12188'`|**Required**: Full version string (10.1.7.12188, for example)|

#### Examples:

```
alteryx_install 'Alteryx Server'
```

```
alteryx_install 'Alteryx Server' do
  source 'http://downloads.alteryx.com/Alteryx10.1.7.11834/AlteryxServerInstallx64_10.1.7.11834.exe'
  version '10.1.7.11834'
end
```

### alteryx_service
Actions: `:disable`, `:enable`, `:manual`, `:restart`, `:start`, `:stop`

Stop/start/restart the AlteryxService and manage automatic start on boot.

#### Examples:

```
# Set service `Startup Type` to `Automatic`.
alteryx_service 'AlteryxService'
```

```
# Set service `Startup Type` to `Automatic`.
alteryx_service 'AlteryxService' do
  action :enable
end
```

```
# Set service `Startup Type` to `Disabled`.
alteryx_service 'AlteryxService'
  action :disable
end
```

```
# Set service `Startup Type` to `Manual`.
alteryx_service 'AlteryxService'
  action :manual
end
```

```
# Restart the AlteryxService.
alteryx_service 'AlteryxService'
  action :restart
end
```

```
# Start the AlteryxService.
alteryx_service 'AlteryxService'
  action :start
end
```

```
# Stop the AlteryxService.
alteryx_service 'AlteryxService'
  action :stop
end
```

### r_install
Actions: `:install`

Install R Predictive Tools for Alteryx Server.

#### Examples:
```
r_install 'R Predictive Tools'
```

### runtimesettings_configure
Actions: `:manage`

Configure RuntimeSettings overrides.

#### Attributes
|Name  |Type  |Default|Description|
|------|------|-------|-----------|
|config           |Hash   |`node['alteryx']['runtimesettings'] = { 'engine' => { 'num_threads' => '2', 'sort_join_memory' => '959' }}`|**Optional**: Configure RuntimeSettings.xml given a hash of settings|
|restart_on_change|Boolean|`node['alteryx']['restart_on_config_change'] = false`|**Optional**: Restart the AlteryxService service when RuntimeSettings.xml has changed.|

##### `config` options
The `config` attribute by default will look for settings under `node['alteryx']['runtimesettings']`. The recommended way to configure properties in `RuntimeSettings.xml` is to set attributes per node or per role under `node['alteryx']['runtimesettings']`. To disable the controller, for example, add the line `default['alteryx']['runtimesettings']['controller']['controller_enabled'] = false` to `attributes/default.rb`.

One could also achieve the same result by passing a hash directly to `runtimesettings_configure`. See the example below.

#### Examples:
```
runtimesettings_configure 'RuntimeSettings.xml'
```

```
runtimesettings_configure 'Configure RuntimeSettings' do
  config(
    controller: {
      controller_enabled: false,
      logging_enabled: true,
      logging_path: 'C:\\Some\\Log\\File.log'
    },
    worker: {
      thread_count: 8
    }
  )
  restart_on_change true
end
```
