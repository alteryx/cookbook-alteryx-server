#
# Cookbook Name:: test
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'
require 'pry'

describe 'alteryx-server::default' do
  context 'When all attributes are default, on Windows' do
    RTS_OVERRIDES_PATH = './spec/unit/files/RuntimeSettings-overrides.xml'
    let(:chef_run) do
      lwrps = %w(alteryx_install
                 r_install
                 alteryx_service
                 runtimesettings_configure)
      runner = ChefSpec::SoloRunner.new(
        platform: 'windows',
        version: '2012r2',
        step_into: lwrps) do |node|
          node.set['alteryx']['r_source'] = 'C:\\test.exe'
          node.set['alteryx']['r_version'] = '3.2.3'
          node.set['alteryx']['rts_defaults_path'] =
            './spec/unit/files/RuntimeSettings-defaults.xml'
          node.set['alteryx']['rts_overrides_path'] = RTS_OVERRIDES_PATH
        end
      runner.converge(described_recipe)
    end

    it 'Converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'Installs Alteryx Server' do
      expect(chef_run).to install_package('Alteryx 10.1 x64')
    end

    it 'Installs R Predictive Tools' do
      expect(chef_run).to install_windows_package(
        'Alteryx Predictive Tools with R 3.2.3'
      )
    end

    it 'Enables the AlteryxService' do
      expect(chef_run).to enable_service('AlteryxService')
    end

    it 'Renders RuntimeSettings.xml' do
      content = <<-EOH.gsub(/^ +/, '')
        <?xml version="1.0" encoding="UTF-8"?>
        <SystemSettings>
        \t<Controller>
        \t\t<ServerSecretEncrypted>2000</ServerSecretEncrypted>
        \t</Controller>
        \t<Engine>
        \t\t<NumThreads>2</NumThreads>
        \t\t<SortJoinMemory>959</SortJoinMemory>
        \t</Engine>
        </SystemSettings>
      EOH
      expect(chef_run).to render_file(RTS_OVERRIDES_PATH).with_content(content)
    end
  end
end
