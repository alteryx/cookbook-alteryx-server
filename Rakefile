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

desc 'Default tests'
task default: %w(unit style)
