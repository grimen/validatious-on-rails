require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

NAME = "validatious_on_rails"
SUMMARY = %Q{Rails plugin that maps model validations to class names on form elements to integrate with Validatious.}
HOMEPAGE = "http://github.com/grimen/#{NAME}"
AUTHORS = ["Christian Johansen", "Jonas Grimfelt"]
EMAIL = "christian@cjohansen.no"
SUPPORT_FILES = %w(README)

begin
  gem 'technicalpickles-jeweler', '>= 1.2.1'
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name        = NAME
    gemspec.summary     = SUMMARY
    gemspec.description = SUMMARY
    gemspec.homepage    = HOMEPAGE
    gemspec.authors     = AUTHORS
    gemspec.email       = EMAIL
    
    gemspec.require_paths = %w{lib}
    gemspec.files = SUPPORT_FILES << %w(Rakefile) << Dir.glob(File.join('{generators,lib,test,rails}', '**', '*').to_s)
    gemspec.executables = %w()
    gemspec.extra_rdoc_files = SUPPORT_FILES
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc %Q{Default: Run unit tests for "#{NAME}".}
task :default => :test

desc %Q{Run unit tests for "#{NAME}".}
Rake::TestTask.new(:test) do |test|
  test.libs << %w(lib test)
  test.pattern = File.join('test', '**', '*_test.rb')
  test.verbose = true
end

desc %Q{Generate documentation for "#{NAME}".}
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = NAME
  rdoc.options << '--line-numbers' << '--inline-source' << '--charset=UTF-8'
  rdoc.rdoc_files.include(SUPPORT_FILES)
  rdoc.rdoc_files.include(File.join('lib', '**', '*.rb'))
end