module AlteryxServer
  # Chef provider for configuring RuntimeSettings.xml overrides
  class RtsProvider < Chef::Provider::LWRPBase
    provides :runtimesettings_configure

    action :manage do
      current_settings =
        AlteryxServer::Helpers.parse_rts(node['alteryx']['rts_path'])
      node.run_state['alteryx'] ||= {}
      node.run_state['alteryx']['rts'] =
        Mash.from_hash(
          AlteryxServer::Helpers.trim_rts_settings(current_settings)
        )

      new_resource.config.each do |top, mid|
        node.run_state['alteryx']['rts'][top] ||= {}
        node.run_state['alteryx']['rts'][top].merge!(mid)
      end

      template node['alteryx']['rts_path'] do
        source 'RuntimeSettings.xml.erb'
        variables config: node.run_state['alteryx']['rts']
        notifies :restart, 'service[AlteryxService]', :delayed
      end
    end
  end
end
