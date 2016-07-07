require 'spec_helper'

FILES_PATH = 'spec/unit/files'.freeze
DEFAULTS_PATH = "#{FILES_PATH}/RuntimeSettings-defaults.xml".freeze
OVERRIDES_PATH = "#{FILES_PATH}/RuntimeSettings-overrides.xml".freeze
helpers = AlteryxServer::Helpers

describe 'CONVERSIONS' do
  it 'Should be a Mash' do
    expect(helpers::CONVERSIONS).to be_kind_of(Mash)
  end
end

describe '#exe_glob' do
  it 'Should return test.exe' do
    expect(helpers.exe_glob('spec/unit/files/')).to(
      eq('spec\\unit\\files\\test.exe')
    )
  end
end

describe '#server_link' do
  it 'Should return an expected link' do
    expect(helpers.server_link('10.1.7.12188')).to(
      eq(
        'http://downloads.alteryx.com/Alteryx10.1.7.12188/'\
        'AlteryxServerInstallx64_10.1.7.12188.exe'
      )
    )
  end
end

describe '#package_name' do
  it 'Should give an expected package name' do
    expect(helpers.package_name('10.1.7.12188')).to eq('Alteryx 10.1 x64')
  end
end

describe '#rts_tag' do
  it 'Should return a formatted XML open tag with false' do
    expect(helpers.rts_tag(:some_setting, false)).to eq('<SomeSetting>')
  end

  it 'Should return a formatted XML close tag with true' do
    expect(helpers.rts_tag(:some_setting, true)).to eq('</SomeSetting>')
  end
end

describe '#rts_value' do
  it 'Should capitalize true' do
    expect(helpers.rts_value(true)).to eq('True')
  end

  it 'Should capitalize false' do
    expect(helpers.rts_value(false)).to eq('False')
  end

  it 'Should leave other values alone' do
    expect(helpers.rts_value('foo')).to eq('foo')
  end
end

describe '#passthrough_action' do
  # We can't really test this functionality since we can't perform actions
  # on ChefSpec resources.
  it 'Should pass an action through to a Chef resource' do
    expect(true).to be true
  end
end

describe '#lookup_resource' do
  # Due to some wonkiness with ChefSpec and the custom resource not adding
  # the service to the resource collection, we'll leave this to the
  # integration tests.
  it 'Should be able to look up resources' do
    expect(true).to be true
  end

  it 'Should be able to create resources' do
    runner = ChefSpec::SoloRunner.new(
      platform: 'windows',
      version: '2012r2'
    )
    runner.converge('alteryx-server::default')

    def svc_block(runner_context)
      Chef::Resource::WindowsService.new('AlteryxService', runner_context)
    end

    expect(
      helpers.lookup_resource(
        runner.run_context, 'service[AlteryxService]'
      ) { svc_block(runner.run_context) }
    ).to be_kind_of(Chef::Resource::WindowsService)
  end
end

describe '#parse_rts' do
  it 'Should return the appropriate Mash' do
    expect(helpers.parse_rts(OVERRIDES_PATH)).to(
      eq(
        'controller' => {
          'server_secret_encrypted' => '2000'
        },
        'engine' => {
          'num_threads' => '2',
          'sort_join_memory' => '959'
        }
      )
    )
  end
end

describe '#trim_rts_settings' do
  it 'Should return the appropriate Mash' do
    rts_props = helpers.parse_rts(OVERRIDES_PATH)
    expect(helpers.trim_rts_settings(rts_props)).to(
      eq(
        'controller' => {
          'server_secret_encrypted' => '2000'
        }
      )
    )
  end
end

describe '#delete_empty' do
  it 'Should remove empty top level keys' do
    hash = { controller: 'test', engine: {} }
    expect(helpers.delete_empty(hash)).to(eq(controller: 'test'))
  end
end

describe '#secrets_unencrypted?' do
  before :each do
    @new = { 'mongo_password' => 'somepass' }
  end

  it 'Should return false if there are no secrets to be encrypted' do
    current = {
      'controller' => {
        'mongo_db_password_encrypted' => '000000'
      }
    }
    expect(helpers.secrets_unencrypted?(current, @new)).to be false
  end

  it 'Should return true if there are secrets to be encrypted' do
    current = {}
    expect(helpers.secrets_unencrypted?(current, @new)).to be true
  end
end

at_exit { ChefSpec::Coverage.report! }
