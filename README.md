alteryx-server Cookbook
================================
This cookbook installs and (in the near future) will configure Alteryx server.

Requirements
------------
- `windows` - alteryx-server only supports the Windows platform.

<!--
Attributes
----------
TODO: List your cookbook attributes here.

e.g.
#### cookbook-alteryx-server::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['cookbook-alteryx-server']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>


Usage
-----
### cookbook-alteryx-server::default

Just include `cookbook-alteryx-server` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[cookbook-alteryx-server]"
  ]
}
```
-->

Recipes
-------
Resources are the intended way to consume this cookbook, however we've provided a single recipe that installs and starts a standalone server.

### default

The default recipe downloads and installs Alteryx server.

Resources
---------

### alteryx_install
Actions: `:install`

Installs Alteryx server.

#### Attributes
|Name  |Type  |Description|
|------|------|-----------|
|source|String|Local path or URL|

Examples:

```
alteryx_install 'Alteryx server'
```

```
alteryx_install 'Alteryx server' do
  source 'http://downloads.alteryx.com/Alteryx10.1.7.11834/AlteryxServerInstallx64_10.1.7.11834.exe'
end
```

<!--
License and Authors
-------------------
Authors: TODO: List authors
-->
