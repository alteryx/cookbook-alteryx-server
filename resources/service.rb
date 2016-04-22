default_action :enable

ayx_svc = 'service[AlteryxService]'

def svc_block
  Chef::Resource::WindowsService.new('AlteryxService', run_context)
end

helpers = AlteryxServer::Helpers

action :enable do
  helpers.passthrough_action(
    run_context,
    ayx_svc,
    :enable
  ) { svc_block }
end

action :disable do
  helpers.passthrough_action(
    run_context,
    ayx_svc,
    :disable
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
