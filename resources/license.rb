property :license, String, name_property: true, required: true
property :key, String
property :email, String
property :skip, [TrueClass, FalseClass]

default_action :activate

load_current_value do
  key node['alteryx']['license']['key']
  email node['alteryx']['license']['email'] unless email
  skip node['alteryx']['license']['skip'] if skip.nil?
  skip false if skip.nil?
end

def activate_license(type, license_address)
  if type == 'key'
    exe = 'C:\\Program Files\\Alteryx\\bin\\AlteryxActivateLicenseKeyCmd.exe'
    cmd = "\"#{exe}\" #{license} \"#{license_address}\""
  elsif type == 'file'
    exe = 'C:\\Program Files\\Alteryx\\bin\\AlteryxLicenseManager.exe'
    cmd = "\"#{exe}\" /InstallSrcLc \"#{license}\""
  else
    raise 'Invalid license type.'
  end

  cmd
end

action :activate do
  lic_type = ::File.exist?(key) ? 'file' : 'key'

  execute 'Activate License' do
    command activate_license(lic_type, email)
    not_if { skip }
  end
end
