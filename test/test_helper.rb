# encoding: utf-8
#
# This file loads up the in-memory database needed to run the tests, and adds a few
# convenience methods.
#

begin
  require File.expand_path(File.join(File.dirname(__FILE__), *%w(.. .. .. .. config environment)))
rescue LoadError
  require 'rubygems'
  
  gem 'test-unit', '1.2.3'
  gem 'activerecord', '>= 1.2.3'
  gem 'actionpack', '>= 1.2.3'
  gem 'sqlite3-ruby', '>= 1.2.0'
  
  require 'test/unit'
  require 'active_record'
  require 'action_controller'
  require 'action_controller'
  require 'sqlite3'
end

begin
  require 'acts_as_fu'
rescue LoadError
  gem 'nakajima-acts_as_fu', '>= 0.0.5'
  require 'acts_as_fu'
end

require 'validatious'

build_model :bogus_items do
  string :url
  string :name
  string :email
  string :num
  string :num2
  string :num3
  
  text    :body
  boolean :signed
  
  validates_presence_of :name, :body
  validates_confirmation_of :name
  validates_acceptance_of :signed
  validates_format_of :url,
    :with => /^(http|https|ftp):\/\/(([A-Z0-9][A-Z0-9_-]*)(\.[A-Z0-9][A-Z0-9_-]*)+)(:(\d+))?\/?/i,
    :name => 'url'
end

#
# ValidationReflection seems to expect RAILS_ROOT to be defined, but it's not
# if it's tested outside of a Rails project. So, just set it to something random.
#
RAILS_ROOT = File.join(File.dirname(__FILE__)) unless defined?(RAILS_ROOT)

#
# Log file for testing only.
#
ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), 'debug.log'))
