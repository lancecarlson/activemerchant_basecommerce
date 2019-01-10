$:.unshift File.expand_path('../lib', __FILE__)

begin
  require 'bundler'
  Bundler.setup
rescue LoadError => e
  puts "Error loading bundler (#{e.message}): \"gem install bundler\" for bundler support."
  require 'rubygems'
end

require 'rake'
require 'rake/testtask'
require 'rubocop/rake_task'
require 'bundler/gem_tasks'

desc 'Run the unit test suite'
task :default => 'test:units'
task :test => 'test:units'

RuboCop::RakeTask.new

namespace :test do
  Rake::TestTask.new(:units) do |t|
    t.pattern = 'test/unit/**/*_test.rb'
    t.libs << 'test'
    t.verbose = true
  end

  desc 'Run all tests that do not require network access'
  task :local => ['test:units', 'rubocop']

  Rake::TestTask.new(:remote) do |t|
    t.pattern = 'test/remote/**/*_test.rb'
    t.libs << 'test'
    t.verbose = true
  end
end