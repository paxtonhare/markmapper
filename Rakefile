require 'rubygems'
require 'bundler/setup'
require 'rake'
require File.expand_path('../lib/mark_mapper/version', __FILE__)

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = 'spec/**/*_spec.rb'
    spec.rspec_opts = ['--color']
  end
  task :default => :spec
rescue LoadError
  nil
end

desc 'Builds the gem'
task :build do
  sh "gem build mark_mapper.gemspec"
end

desc 'Builds and installs the gem'
task :install => :build do
  sh "gem install mark_mapper-#{MarkMapper::Version}"
end

desc 'Tags version, pushes to remote, and pushes gem'
task :release => :build do
  sh "git tag v#{MarkMapper::Version}"
  sh "git push origin master"
  sh "git push origin v#{MarkMapper::Version}"
  sh "gem push mark_mapper-#{MarkMapper::Version}.gem"
end
