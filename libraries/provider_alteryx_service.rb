module AlteryxServer
  # Chef provider for installing R Predictive Tools
  class AlteryxServiceProvider < Chef::Provider::LWRPBase
    provides :alteryx_service

    ayx_svc = 'service[AlteryxService]'

    def svc_block
      service 'AlteryxService' do
        supports restart: true
        action :nothing
      end
    end

    helpers = AlteryxServer::Helpers

    action :disable do
      helpers.passthrough_action(
        run_context,
        ayx_svc,
        :disable
      ) { svc_block }
    end

    action :enable do
      helpers.passthrough_action(
        run_context,
        ayx_svc,
        :enable
      ) { svc_block }
    end

    action :manual do
      helpers.passthrough_action(
        run_context,
        ayx_svc,
        :configure_startup,
        startup_type: :manual
      ) { svc_block }
    end

    action :restart do
      helpers.passthrough_action(
        run_context,
        ayx_svc,
        :restart
      ) { svc_block }
    end

    action :start do
      helpers.passthrough_action(
        run_context,
        ayx_svc,
        :start
      ) { svc_block }
    end

    action :stop do
      helpers.passthrough_action(
        run_context,
        ayx_svc,
        :stop
      ) { svc_block }
    end
  end
end
