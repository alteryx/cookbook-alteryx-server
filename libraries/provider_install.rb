class Chef
  class Provider
    # Chef provider for installing Alteryx server
    class AlteryxServerInstall < Chef::Provider::LWRPBase
      include Chef::DSL::IncludeRecipe

      provides :alteryx_install if respond_to?(:provides)

      action :install do
        package 'Alteryx 10.1 x64' do
          source new_resource.source.to_s
          options '/s'
          action :install
        end
      end
    end
  end
end
