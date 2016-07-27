#!/usr/bin/env rake

namespace :style do
  desc 'Run cookstyle ruby lint tests'
  require 'cookstyle'
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:cookstyle) do |t|
    t.options << '--display-cop-names'
  end

  desc 'Run foodcritic Chef lint tests'
  require 'foodcritic'
  FoodCritic::Rake::LintTask.new(:foodcritic) do |t|
    t.options = { fail_tags: ['any'], epic_fail: true }
  end
end
task style: %w(style:cookstyle style:foodcritic)

namespace :unit do
  desc 'Run rspec unit tests'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = ['spec/unit/**/*_spec.rb']
  end
end
task unit: %w(unit:spec)

namespace :integration do
  begin
    desc 'Run integration tests'
    require 'kitchen/rake_tasks'
    Kitchen::RakeTasks.new
  rescue LoadError
    puts '>>>>> test-kitchen gem not loaded, omitting tasks.' unless ENV['CI']
  end
end
task integration: %w(integration:kitchen:all)

namespace :stove do
  require 'stove/rake_task'
  Stove::RakeTask.new
end
task publish: 'stove:publish'

desc 'Default tasks (unit & style)'
task default: %w(unit style)

desc 'All tasks'
task all: %w(unit style integration)
