require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rbconfig'
require_relative 'lib/pmlatex/version'

RSpec::Core::RakeTask.new(:spec)
task default: :spec

desc 'Test, strictly build, and verify an isolated installed package'
task verify: :spec do
  mkdir_p 'pkg'
  archive = "pkg/pmlatex-#{Pmlatex::VERSION}.gem"
  ruby '-rrubygems/gem_runner', '-e', 'Gem::GemRunner.new.run(ARGV)', '--',
       'build', 'pmlatex.gemspec', '--strict', '--output', archive
  ruby 'script/verify_package.rb', archive
end
