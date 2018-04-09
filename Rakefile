#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'bundler/setup'
require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new('spec') do |task|
  task.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec
