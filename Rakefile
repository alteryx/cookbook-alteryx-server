#!/usr/bin/env rake

namespace :cookbook do
  desc 'Run all tasks'
  task all: [:spec, :style, :foodcritic]

  desc 'Run rspec unit tests'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = ['spec/unit/**/*_spec.rb']
  end

  desc 'Run cookstyle ruby lint tests'
  require 'cookstyle'
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:style) do |t|
    t.options << '--display-cop-names'
  end

  desc 'Run foodcritic Chef lint tests'
  require 'foodcritic'
  FoodCritic::Rake::LintTask.new(:foodcritic) do |t|
    t.options = { fail_tags: ['any'], epic_fail: true }
  end
end
