module AlteryxServer
  # Chef resource for installing R Predictive tools
  class AlteryxServiceResource < Chef::Resource::LWRPBase
    resource_name :alteryx_service
    provides :alteryx_service

    actions(:disable, :enable, :manual, :restart, :start, :stop)
    default_action :enable
  end
end
