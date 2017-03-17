#
# Cookbook Name:: test
# Spec:: uninstall
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'alteryx-server::uninstall' do
  context 'When all uninstalling packages' do
    let(:chef_run) do
      lwrps = %w(alteryx_server_package
                 alteryx_server_r_package)
      runner = ChefSpec::SoloRunner.new(
        platform: 'windows',
        version: '2012R2',
        step_into: lwrps)
      runner.converge(described_recipe)
    end

    it 'Sends the uninstall action to alteryx_server_r_package' do
      expect(chef_run).to(
        uninstall_alteryx_server_r_package('Alteryx Predictive Tools')
      )
    end
    it 'Sends the uninstall action to alteryx_server_package' do
      expect(chef_run).to uninstall_alteryx_server_package('Alteryx Server')
    end
  end
end
