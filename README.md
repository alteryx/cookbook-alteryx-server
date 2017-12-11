alteryx-server Cookbook
================================
[![Build Status](https://travis-ci.org/alteryx/cookbook-alteryx-server.svg?branch=master)](https://travis-ci.org/alteryx/cookbook-alteryx-server) [![Cookbook Version](https://img.shields.io/cookbook/v/alteryx-server.svg)](https://supermarket.chef.io/cookbooks/alteryx-server)

A Chef cookbook to install and configure Alteryx Server.

Requirements
------------
- `windows` - alteryx-server only supports the Windows platform.
- `chef-client >= 12.7.2` - alteryx-server only supports chef-client versions of 12.7.2 or above.

Scope
-----
Resources are the intended way to consume this cookbook, however we've provided a couple of example recipes that install, configure, and license a standalone server.

### Recipes

#### default

The default recipe downloads, installs, and configures Alteryx Server as well as Alteryx R Predictive Tools.

#### license

This recipe licenses Alteryx Server and starts AlteryxService.

### Limitations

- No functionality exists to check if the desired license is already activated. Use the `node['alteryx']['license']['skip']` attribute or the `skip` property in the `alteryx_server_license` resource to skip activation.
- `mongo_db_search_password_encrypted` and `mongo_db_web_password_encrypted` cannot be set through `secrets` property in the `alteryx_server_runtimesettings` resource. To set these connections, one either has to configure them through the configuration GUI or put them in plain text in `mongo_db_search_override` and `mongo_db_web_override`, respectively.

Resources
---------

### alteryx_server_package
Actions: `:install`, `:uninstall`

Install Alteryx Server.

#### Attributes
|Name  |Type  |Default|Description|
|------|------|-------|-----------|
|source|String|`node['alteryx']['source'] = nil`  |**Optional**: Local path or URL<br/>The installer will download from alteryx.com using `version` unless `source` is specified.|
|version|String|`node['alteryx']['version'] = '11.7.4.37815'`|**Required**: Full version string (11.7.4.37815, for example)|

#### Examples:

```ruby
# Install latest version of Alteryx Server
alteryx_server_package 'Alteryx Server'
```

```ruby
# Install specified version of Alteryx Server
alteryx_server_package 'Alteryx Server' do
  source 'http://downloads.alteryx.com/Alteryx11.7.4.37815/AlteryxServerInstallx64_11.7.4.37815.exe'
  version '11.7.4.37815'
end
```
```ruby
# Uninstall Alteryx Server
alteryx_server_package 'Alteryx Server' do
  action :uninstall
end
```

### alteryx_server_license
Actions: `:activate`

Activate an Alteryx Server license.

**Important**: Each node must have a unique e-mail address for the license key, otherwise the license seat will be moved to whichever node licensed the seat last.

#### Attributes
|Name  |Type  |Default|Description|
|------|------|-------|-----------|
|email |String|`node['alteryx']['license']['email'] = nil`|**Required**: Unique e-mail address to give to a licensed seat.|
|skip |Boolean|`node['alteryx']['license']['skip'] = false`|**Optional**: Whether or not to skip a license activation.|

#### Examples

```ruby
# Replace xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx with your key
alteryx_server_license 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' do
  email 'test@example.com'
end
```

```ruby
# Replace xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx with your key
alteryx_server_license 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' do
  email 'test@example.com'
  skip true
end
```
### alteryx_server_service
Actions: `:disable`, `:enable`, `:manual`, `:restart`, `:start`, `:stop`

Stop/start/restart the AlteryxService and manage automatic start on boot.

#### Examples:

```ruby
# Set service `Startup Type` to `Automatic`.
alteryx_server_service 'AlteryxService'
```

```ruby
# Set service `Startup Type` to `Automatic`.
alteryx_server_service 'AlteryxService' do
  action :enable
end
```

```ruby
# Set service `Startup Type` to `Disabled`.
alteryx_server_service 'AlteryxService' do
  action :disable
end
```

```ruby
# Set service `Startup Type` to `Manual`.
alteryx_server_service 'AlteryxService' do
  action :manual
end
```

```ruby
# Restart the AlteryxService.
alteryx_server_service 'AlteryxService' do
  action :restart
end
```

```ruby
# Start the AlteryxService.
alteryx_server_service 'AlteryxService' do
  action :start
end
```

```ruby
# Stop the AlteryxService.
alteryx_server_service 'AlteryxService' do
  action :stop
end
```

```ruby
# Enable and start the AlteryxService.
alteryx_server_service 'AlteryxService' do
  action [:enable, :start]
end
```

### alteryx_server_r_package
Actions: `:install`, `:uninstall`

Install R Predictive Tools for Alteryx Server.

#### Attributes
|Name   |Type  |Default|Description|
|-------|------|-------|-----------|
|source |String|`node['alteryx']['r_source'] = nil`|**Optional**: A URL or file path for the R Installer exe.<br/>**Important**:<ul><li>The `version` attribute must also be set if `source` is set.</li><li>If `version` is set to `nil`, the package will be installed with the exe at `C:\Program Files\Alteryx\RInstaller\`.</li></ul>|
|version|String|`node['alteryx']['r_version'] = nil`|**Optional**: The version of R to install.<br/>**Required**: If `source` is set.|

#### Examples:
```ruby
# Install latest version of R Prodictive Tools
alteryx_server_r_package 'R Predictive Tools'
```

```ruby
# Install specified version of R Prodictive Tools
alteryx_server_r_package 'R Predictive Tools' do
  source 'http://downloads.alteryx.com/Alteryx11.7.4.37815/RInstaller_11.7.4.37815.exe'
  version '3.3.2'
end
```
```ruby
# Uninstall Alteryx Server
alteryx_server_package 'Alteryx Server' do
  action :uninstall
end
```

### alteryx_server_runtimesettings
Actions: `:manage`

Configure RuntimeSettings overrides.

#### Attributes
|Name  |Type  |Default|Description|
|------|------|-------|-----------|
|config           |Hash   |`node['alteryx']['runtimesettings'] = {`<br/>  `'engine' => { 'num_threads' => node['cpu']['total'] + 1,`<br/>  `'sort_join_memory' =>`<br/>    `(node['kernel']['os_info']['total_visible_memory_size'].to_i`<br/>      `* 0.8 / 1024 / (node['cpu']['total'] + 1)).to_i } }`|**Optional**: Configure RuntimeSettings.xml given a hash of settings. `num_threads` is set to the number of cores plus one. `sort_join_memory` is set to 80% of the total memory divided by `num_threads`.|
|restart_on_change|Boolean|`node['alteryx']['restart_on_change'] = false`|**Optional**: Restart the AlteryxService service when RuntimeSettings.xml has changed.|
|secrets          |Hash   |`nil`|**Optional**: A hash of secrets/passwords to be encrypted. See the examples section below for valid options.<br/><br/>By default we set this to `nil` instead of a `node` attribute as these values should be stored securely. Look at encrypted databags, chef-vault, citadel and others.|

##### `config` options
The `config` attribute by default will look for settings under `node['alteryx']['runtimesettings']`. The recommended way to configure properties in `RuntimeSettings.xml` is to set attributes per node or per role under `node['alteryx']['runtimesettings']`. To disable the controller, for example, add the following line to `attributes/default.rb`:
```ruby
default['alteryx']['runtimesettings']['controller']['controller_enabled'] = false
```

One could also achieve the same result by passing a hash directly to `alteryx_server_runtimesettings`. See the example below.

#### Examples:
```ruby
alteryx_server_runtimesettings 'RuntimeSettings.xml'
```

```ruby
alteryx_server_runtimesettings 'Configure RuntimeSettings' do
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
    execute_user: {
      user: node['alteryx']['runtimesettings']['worker']['execute_user_name'],
      domain: node['alteryx']['runtimesettings']['worker']['execute_domain'],
      password: 'somesupersecretexecutepassword'
    },
    mongo_password: 'somesupersecretmongopassword',
    remote_secret: 'thecontrollerssecret',
    server_secret: 'thelocalserversecret',
    smtp_password: 'somesupersecretsmtppassword'
  )
  restart_on_change true
end
```
#### Options
##### `controller` options
The following contains available options and descriptions for child settings under the `controller` attribute.

|Name|Type|Default value|Description|
|----|----|-------------|-----------|
|cleanup_queue_inputs_time_to_live|`Integer`<br/>(min)|`0`|The age of queue input items (uploaded files) before `Time.now` to remove. Tuning this setting may help to reduce the amount of drive space necessary as the system is used.|
|cleanup_queue_time_to_live|`Integer`<br/>(min)|`0`|The age of queue items and results before `Time.now` to remove. Tuning this setting may help to reduce the amount of drive space necessary as the system is used.|
|cleanup_scheduler_time_to_live|`Integer`<br/>(min)|`0`|The age of scheduler items before `Time.now` to remove. Tuning this setting may help to reduce the amount of drive space necessary as the system is used.|
|controller_enabled|`Boolean`|`true`|`true` if this node is the Controller, `false` if not. Only run one Controller per Server.|
|embedded_mongo_db_enabled|`Boolean`|`false`|`true` if Embedded MongoDB is enabled (default for Private Server), `false` if using SQLite or User-managed MongoDB.|
|embedded_mongo_db_root_path|`String`|`'C:\\ProgramData\\`<br/>`Alteryx\\Service\\`<br/>`Persistence\\Mongo'`|Necessary only if you are using Embedded MongoDB. The root path is the location where database files should be stored.|
|gallery_enabled|`Boolean`|`false`|`true` if this node is a Gallery, `false` otherwise.|
|logging_enabled|`Boolean`|`false`|If `true`, logging is enabled otherwise logging disabled.|
|logging_file_max_size|`Integer`<br/>(mb)|`10`|Approximate log file size before rotating.|
|logging_path|`String`|`'C:\\ProgramData\\`<br/>`Alteryx\\Service\\`<br/>`AlteryxServiceLog.`<br/>`log'`|Full path to log file.|
|logging_rotation_enabled|`Boolean`|`true`|If `true`, rotate log file when it reaches approximate size limit.|
|logging_severity_threshold|`Integer`|`6`|`0-7`: Minimum Syslog logging level, suggested is minimum `5`, `7` is Debug (highest).|
|map_tile_disk_cache_max_size|`Integer`<br/>(mb)|`1024`|This is the maximum amount of space to consume for caching tiles on the hard drive. A higher disk cache will result in greater consumption of drive space, but may increase performance of map tile requests.|
|map_tile_mem_cache_max_size|`Integer`|`10000`|This is the maximum number of map tiles that will be stored in memory. 1,000 tiles will require roughly 450MB of memory. A higher memory cache will result in more tiles being stored to increase performance, but will require more system resources.|
|map_tile_reference_layers_time_to_live|`Integer`<br/>(sec)|`86400`|The amount of time to persist reference layer information. Increasing this number may help optimize performance of frequently requested layers. If a reference layer expires, it will be generated again the next time it is requested.|
|mongo_db_database_name|`String`|`nil`|Name of the Service database in User-managed MongoDB instance.|
|mongo_db_enabled|`Boolean`|`false`|If `true` use User-managed MongoDB, otherwise use either (Embedded MongoDB or SQLite).|
|mongo_db_password_encrypted|`String`|`nil`|If using auth on MongoDB, encrypted MongoDB password. Set using `mongo_password` in the `secrets` property of the `alteryx_server_runtimesettings` resource.|
|mongo_db_server_name|`String`|`nil`|MongoDB server name as `host:port`.|
|mongo_db_user_name|`String`|`nil`|If using auth on MongoDB, valid username for MongoDB.|
|scheduler_auto_connect_enabled|`Boolean`|`true`|Enabling this setting will allow users on this machine to auto-connect to the Scheduler. You may need to enable this if you are having difficulties connecting to the Scheduler.|
|server_secret_encrypted|`String`|`nil`|Encrypted server secret. Set using `server_secret` in the `secrets` property of the `alteryx_server_runtimesettings` resource.|
|sqlite_path|`String`|`'C:\\ProgramData\\`<br/>`Alteryx\\Service`<br/>`\\Persistence'`|Necessary only if you are using SQLite. The root path is the location where database files should be stored.|
|web_interface_staging_path|`String`|`node['alteryx']`<br/>`['runtimesettings']`<br/>`['worker']['staging_path']`|The web interface staging path is the location where the Controller will write any necessary temporary or cache files. This setting should point to a location that is safe to write large amounts of files.|

##### `engine` options
The following contains available options and descriptions for child settings under the `engine` attribute.

|Name|Type|Default value|Description|
|----|----|-------------|-----------|
|browse_everywhere_limit_per_anchor|`Integer`<br/>(bytes)|`1024`|This is the current amount of memory that each Browse Everywhere anchor will consume.|
|default_temp_file_path|`String`|`'C:\\ProgramData\\`<br/>`Alteryx\\Engine'`|The path where temporary files used in processed workflows and apps will be placed. This setting should point to a location that is safe to write large amounts of files.|
|log_file_path|`String`|`'C:\\ProgramData\\`<br/>`Alteryx\\Engine'`|Each time a workflow or app is run, output logs are produced. These logs will be written to the directory specified in this setting. A blank logging directory will disable logging.|
|num_threads|`Integer`|`nil`|Some tools and operations can take advantage of multiple processing threads. Generally, this value should not be changed, and the default value is the number of available processor cores plus one.|
|package_staging_path|`String`|`'C:\\ProgramData\\`<br/>`Alteryx\\Engine\\Staging'`|Each time a workflow or app is run, output logs are produced. These logs will be written to the directory specified in this setting. A blank logging directory will disable logging.|
|proxy_configuration|`String`|`nil`|If present, proxy server configuration used by Download tool.|
|run_at_lower_priority|`Boolean`|`false`|If `true`, run Engine process at a lower system priority level (recommended to ensure AlteryxService functionality under high Engine load).|
|sort_join_memory|`Integer`|`0`|This is the minimum amount of memory that the Engine will consume while performing operations such as Sorts and Joins within a workflow or app. Generally, this value should not be changed. `0` is unlimited.|
|user_alias_override|`Boolean`|`false`|With this option, any user alias that is specified in the Alias Repository can take priority over a system alias.|
|user_lock_down|`Boolean`|`false`|If `false`, allow user settings to override temp path and memory settings, otherwise use system settings.|

##### `gallery` options
The following contains available options and descriptions for child settings under the `gallery` attribute.

|Name|Type|Default value|Description|
|----|----|-------------|-----------|
|authentication_type|`String`|`'BuiltIn'`|`'BuiltIn'`, `'Windows'`, or `'Kerberos'`<br/><br/>Alteryx Server supports built-in authentication as well as Integrated Windows Authentication either with or without Kerberos support. `BuiltIn` authentication uses email address and passwords to log in, while the `Windows` and `Kerberos` options utilize your internal network credentials.<br/><br/>**Note:** Once an authentication type has been selected, it should not be changed. Changing it may cause technical problems.|
|base_address|`String`|`'http://`<br/>`localhost/`<br/>`gallery/'`|This is the URL that users will go to when they visit the Gallery. Although the domain configuration must be done elsewhere, this setting is used in areas such as email content when links to workflows are made available.<br/><br/>If SSL is enabled and your listener is on a port other than 443, be sure to specify the port in this setting (ex. https://localhost:445/alteryxcloud)|
|default_gallery_admin_user_name|`String`|`nil`|To manage users, workflows, etc., an administrator account must be created. If `authentication_type` is set to `BuiltIn`, enter the email address of the administrator (ex. me@example.com). If `authentication_type` is set to `Windows` or `Kerberos`, specify the user account (ex. Domain\Username).|
|default_run_mode|`String`|`'Unrestricted'`|`'Unrestricted'`, `'Semi Safe'`, or `'Safe'`<br/><br/>Workflows in the Server can be configured to run with certain permissions, limiting or allowing certain tools in the workflow to be used. To prevent potentially malicious workflows from being executed, set this to `'Safe'`. Lowering the restriction will allow tools, such as the Run Command Tool, to be used in Workflows.|
|elastic_search_index_name|`String`|`'alteryx-gallery'`|Only needed if `search_provider` is set to `Elasticsearch`. Name of the Elasticsearch database.|
|elastic_search_url|`String`|`nil`|Only needed if `search_provider` is set to `Elasticsearch`. URL of the Elasticsearch provider.|
|logging_path|`String`|`'C:\\`<br/>`ProgramData\\`<br/>`Alteryx\\`<br/>`Gallery\\`<br/>`Logs'`|Full path to log directory.|
|mongo_db_search_connection|`String`|`nil`|Full MongoDB connection string used for Search database, e.g., `mongodb://user:pass@host/Alteryx_Lucene`.|
|mongo_db_search_database_name|`String`|`'Alteryx`<br/>`Gallery_`<br/>`Lucene'`|Name of Search database in MongoDB instance.|
|mongo_db_search_override|`Boolean`|`false`|If `true`, use MongoDBSearchConnection otherwise build connection string from search parameters (`mongo_db_search_database_name`, `mongo_db_search_password_encrypted`, `mongo_db_search_server_name`, and `mongo_db_search_user_name`).  If `false`, use Controller connection info.|
|mongo_db_search_password_encrypted|`String`|`nil`|If using auth on MongoDB, encrypted MongoDB password used for Search database.|
|mongo_db_search_server_name|`String`|`nil`|MongoDB Search server name as `host:port`.|
|mongo_db_search_user_name|`String`|`nil`|If using auth on MongoDB, user name used for Search database. e.g., `mongodb://user:pass@host/AlteryxGallery`.|
|mongo_db_web_connection|`String`|`nil`|Full MongoDB connection string used for Gallery database.|
|mongo_db_web_database_name|`String`|`'Alteryx`<br/>`Gallery'`|Name of Gallery database in MongoDB instance.|
|mongo_db_web_override|`Boolean`|`false`|If `true`, use MongoDBWebConnection otherwise build connection string from web parameters (`mongo_db_web_database_name`, `mongo_db_web_password_encrypted`, `mongo_db_web_server_name`, and `mongo_db_web_user_name`).  If `false`, use Controller connection info.|
|mongo_db_web_password_encrypted|`String`|`nil`|If using auth on MongoDB, encrypted MongoDB password used for Gallery database.|
|mongo_db_web_server_name|`String`|`nil`|MongoDB Gallery server name as `host:port`.|
|mongo_db_web_user_name|`String`|`nil`|If using auth on MongoDB, valid username for Gallery database.|
|search_provider|`String`|`'Lucene'`|`'Lucene'` or `'Elasticsearch'`<br/><br/>Name of the search engine used by the Gallery.|
|smtp_email|`String`|`nil`|Email address used to send Gallery email alerts.|
|smtp_enabled|`Boolean`|`true`|If `true`, enable email events on the Gallery, otherwise disable.|
|smtp_password_encrypted|`String`|`nil`|Encrypted password used to log into SMTP server when sending Gallery email alerts. Set using `smtp_password` in the `secrets` property of the `alteryx_server_runtimesettings` resource.|
|smtp_port|`Integer`|`25`|Port on SMTP server used to send Gallery email alerts.|
|smtp_server_name|`String`|`nil`|SMTP server name used for Gallery email alerts.|
|smtp_ssl_enabled|`Boolean`|`false`|If `true`, enable SSL for SMTP connections, otherwise disable.|
|smtp_user_name|`String`|`nil`|Username used to log into to SMTP server when sending Gallery email alerts.|
|ssl_enabled|`Boolean`|`false`|If `true`, enable SSL connections from Client to Gallery (https), otherwise use http connections.|
|working_path|`String`|`'C:\\`<br/>`ProgramData\\`<br/>`Alteryx\\`<br/>`Gallery'`|The workspace is where the Gallery will write any necessary temporary files. This setting should point to a location that is safe to write large amounts of files.|

##### `worker` options
The following contains available options and descriptions for child settings under the `worker` attribute.

|Name|Type|Default value|Description|
|----|----|-------------|-----------|
|execute_domain|`String`|`nil`|The optional domain for the provided username that will be used to run the Engine on the Queue Worker.|
|execute_password_encrypted|`String`|`nil`|The encrypted password corresponding to the user that will run the Engine on the Queue Worker.|
|execute_user_name|`String`|`nil`|If non-empty, the username that will be used to run the Engine on the Queue Worker.|
|quality_of_service_min|`Integer`|`0`|`0-9`: Quality of Service is used to manage resource allocation in a multi-node deployment. For normal operation, leave this setting at 0.|
|queue_worker_enabled|`Boolean`|`true`|Enabling this machine to run scheduled Alteryx workflows will allow it to take requests to run workflows from the Scheduler or from the Gallery. In multi-node deployments, you may want to set this attribute to `false` if you have another machine that will be running workflows.|
|render_worker_count|`Integer`|`2`|The number of Render Workers to run on this node (the number of `AlteryxService_RenderWorker.exe` executables).|
|render_worker_enabled|`Boolean`|`true`|Enabling this machine to act as a Map Worker will allow it to render map tiles for Map Questions and the Map Input Tool. In multi-node deployments, you may want to set this attribute to `false` if you have another machine that will process map tile requests, and if this one will be dedicated to running scheduled workflows.|
|server_name|`String`|`nil`|The Controller as `server:port` to which this worker connects.|
|server_secret_encrypted|`String`|`nil`|The encrypted server secret corresponding to the current Controller. Set using `remote_secret` in the `secrets` property of the `alteryx_server_runtimesettings` resource.|
|sort_join_memory|`Integer`|`0`|Enabling this machine to act as a Map Worker will allow it to render map tiles for Map Questions and the Map Input Tool. In multi-node deployments, you may want to uncheck this option if you have another machine that will process map tile requests, and if this one will be dedicated to running scheduled workflows. `0` is unlimited.|
|staging_path|`String`|`'C:\\ProgramData\\`<br/>`Alteryx\\Service\\Staging'`|Path to staging directory. Location where packages are unpacked for execution by a compute slave etc etc.|
|thread_count|`Integer`|`1`|This is the maximum number of workflows that are allowed to run simultaneously on this machine. Your license may already have a limitation, and setting this to a number higher than the license may result in errors.|
|timeout|`Integer`<br/>(sec)|`0`|If you do not want jobs to run for an extended period of time, you can use this setting to force jobs to cancel after a certain amount of time has passed. This will help to free up system resources that might otherwise be taken up by unintentionally long running jobs. `0` is unlimited.|
|use_local_server|`Boolean`|`true`|If `true`, default to using localhost:80 as the server and retrieve server secret.  Otherwise, use provided server and server secret.|

Testing
-------
Refer to `TESTING.md`.

Contributing
------------
Refer to `CONTRIBUTING.md`.

License
-------
This software is licensed under the Apache 2 license, quoted below.

    Copyright (c) 2016 Alteryx, Inc. <http://www.alteryx.com/>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
