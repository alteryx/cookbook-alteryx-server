if defined?(ChefSpec)
  def install_alteryx_server_package(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :alteryx_server_package, :install, resource_name)
  end

  def install_alteryx_server_r_package(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :alteryx_server_r_package, :install, resource_name)
  end

  def uninstall_alteryx_server_package(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :alteryx_server_package, :uninstall, resource_name)
  end

  def uninstall_alteryx_server_r_package(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :alteryx_server_r_package, :uninstall, resource_name)
  end

  def enable_alteryx_server_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :alteryx_server_service, :enable, resource_name)
  end

  def manage_alteryx_server_runtimesettings(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :alteryx_server_runtimesettings, :manage, resource_name)
  end
end
