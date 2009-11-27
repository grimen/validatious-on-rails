# encoding: utf-8
require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

NAME = "validatious-on-rails"
SUMMARY = %Q{Rails plugin that maps model validations to class names on form elements to integrate with Validatious.}
HOMEPAGE = "http://github.com/grimen/#{NAME}"
AUTHORS = ["Jonas Grimfelt", "Christian Johansen"]
EMAIL = "grimen@gmail.com"
SUPPORT_FILES = %w(README)

begin
  gem 'jeweler', '>= 1.2.1'
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name        = NAME
    gemspec.summary     = SUMMARY
    gemspec.description = SUMMARY
    gemspec.homepage    = HOMEPAGE
    gemspec.authors     = AUTHORS
    gemspec.email       = EMAIL
    
    gemspec.require_paths = %w{lib}
    gemspec.files = SUPPORT_FILES << %w(Rakefile) <<
      Dir.glob(File.join(*%w[{app,config,generators,lib,test} ** *]).to_s).reject { |v| v =~ /\.log/i }
    gemspec.executables = %w[]
    gemspec.extra_rdoc_files = SUPPORT_FILES
    
    gemspec.add_dependency 'validation_reflection', '>= 0.3.5'
    gemspec.add_dependency 'activerecord',          '>= 1.2.3'
    gemspec.add_dependency 'actionpack',            '>= 1.2.3'
    gemspec.add_dependency 'activesupport',         '>= 1.2.3'
    
    gemspec.add_development_dependency 'test-unit',     '= 1.2.3'
    gemspec.add_development_dependency 'rr',            '> 0.10.0'
    gemspec.add_development_dependency 'sqlite3-ruby',  '> 1.2.0'
    gemspec.add_development_dependency 'redgreen',      '> 0.10.4'
    gemspec.add_development_dependency 'context',       '> 0.5.5'
    gemspec.add_development_dependency 'acts_as_fu',    '> 0.0.5'
  end
rescue LoadError
  puts "Jeweler - or one of it's dependencies - is not available. Install it with: sudo gem install jeweler -s http://gemcutter.org"
end

desc %Q{Default: Run unit tests for "#{NAME}".}
task :default => :test

desc %Q{Run unit tests for "#{NAME}".}
Rake::TestTask.new(:test) do |test|
  test.libs << %w[lib test]
  test.pattern = File.join(*%w[test ** *_test.rb])
  test.verbose = true
end

desc %Q{Generate documentation for "#{NAME}".}
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = NAME
  rdoc.options << '--line-numbers' << '--inline-source' << '--charset=UTF-8'
  rdoc.rdoc_files.include(SUPPORT_FILES)
  rdoc.rdoc_files.include(File.join(*%w[lib ** *.rb]))
end