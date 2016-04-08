alteryx-server Cookbook
================================
A Chef cookbook to install and configure Alteryx Server.

Requirements
------------
- `windows` - alteryx-server only supports the Windows platform.
- `chef-client >= 12.7.2` - alteryx-server only supports chef-client versions of 12.7.2 or above

Recipes
-------
Resources are the intended way to consume this cookbook, however we've provided a single recipe that installs and configures a standalone server.

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
|source|String|`node['alteryx']['source'] = nil`  |**Optional**: Local path or URL<br/>The installer will download from alteryx.com using `version` unless `source` is specified.|
|version|String|`node['alteryx']['version'] = '10.1.7.12188'`|**Required**: Full version string (10.1.7.12188, for example)|

#### Examples:

```ruby
alteryx_install 'Alteryx Server'
```

```ruby
alteryx_install 'Alteryx Server' do
  source 'http://downloads.alteryx.com/Alteryx10.1.7.11834/AlteryxServerInstallx64_10.1.7.11834.exe'
  version '10.1.7.11834'
end
```

### alteryx_service
Actions: `:disable`, `:enable`, `:manual`, `:restart`, `:start`, `:stop`

Stop/start/restart the AlteryxService and manage automatic start on boot.

#### Examples:

```ruby
# Set service `Startup Type` to `Automatic`.
alteryx_service 'AlteryxService'
```

```ruby
# Set service `Startup Type` to `Automatic`.
alteryx_service 'AlteryxService' do
  action :enable
end
```

```ruby
# Set service `Startup Type` to `Disabled`.
alteryx_service 'AlteryxService' do
  action :disable
end
```

```ruby
# Set service `Startup Type` to `Manual`.
alteryx_service 'AlteryxService' do
  action :manual
end
```

```ruby
# Restart the AlteryxService.
alteryx_service 'AlteryxService' do
  action :restart
end
```

```ruby
# Start the AlteryxService.
alteryx_service 'AlteryxService' do
  action :start
end
```

```ruby
# Stop the AlteryxService.
alteryx_service 'AlteryxService' do
  action :stop
end
```

```ruby
# Enable and start the AlteryxService.
alteryx_service 'AlteryxService do
  action [:enable, :start]
end
```

### r_install
Actions: `:install`

Install R Predictive Tools for Alteryx Server.

#### Attributes
|Name   |Type  |Default|Description|
|-------|------|-------|-----------|
|source |String|`node['alteryx']['r_source'] = nil`|**Optional**: A URL or file path for the R Installer exe.<br/>**Important**:<ul><li>The `version` attribute must also be set if `source` is set.</li><li>If `version` is set to `nil`, the package will be installed with the exe at `C:\Program Files\Alteryx\RInstaller\`.</li></ul>|
|version|String|`node['alteryx']['r_version'] = nil`|**Optional**: The version of R to install.<br/>**Required**: If `source` is set.|

#### Examples:
```ruby
r_install 'R Predictive Tools'
```

```ruby
r_install 'R Predictive Tools' do
  source 'http://downloads.alteryx.com/Alteryx10.1.6.11313/RInstaller_10.1.6.11313.exe'
  version '3.1.3'
end
```

### runtimesettings_configure
Actions: `:manage`

Configure RuntimeSettings overrides.

#### Attributes
|Name  |Type  |Default|Description|
|------|------|-------|-----------|
|config           |Hash   |`node['alteryx']['runtimesettings'] = { 'engine' => { 'num_threads' => '2', 'sort_join_memory' => '959' }}`|**Optional**: Configure RuntimeSettings.xml given a hash of settings|
|restart_on_change|Boolean|`node['alteryx']['restart_on_config_change'] = false`|**Optional**: Restart the AlteryxService service when RuntimeSettings.xml has changed.|
|secrets          |Hash   |`nil`|**Optional**: A hash of secrets/passwords to be encrypted. See the examples section below for valid options.<br/><br/>By default we set this to `nil` instead of a `node` attribute as these values should be stored securely. Look at encrypted databags, chef-vault, citadel and others.|

##### `config` options
The `config` attribute by default will look for settings under `node['alteryx']['runtimesettings']`. The recommended way to configure properties in `RuntimeSettings.xml` is to set attributes per node or per role under `node['alteryx']['runtimesettings']`. To disable the controller, for example, add the following line to `attributes/default.rb`:
```ruby
default['alteryx']['runtimesettings']['controller']['controller_enabled'] = false
```

One could also achieve the same result by passing a hash directly to `runtimesettings_configure`. See the example below.

#### Examples:
```ruby
runtimesettings_configure 'RuntimeSettings.xml'
```

```ruby
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
  ),
  secrets(
    mongo_password: 'somesupersecretmongopassword',
    remote_secret: 'thecontrollerssecret',
    server_secret: 'thelocalserversecret',
    smtp_password: 'somesupersecretsmtppassword'
  )
  restart_on_change true
end
```
