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
  require 'sqlite3'
end

begin
  require 'context'
rescue LoadError
  gem 'jeremymcanally-context', '>= 0.5.5'
  require 'context'
end

begin
  require 'rr'
rescue LoadError
  gem 'rr', '>= 0.0.0'
  require 'rr'
end
extend RR::Adapters::RRMethods

begin
  require 'acts_as_fu'
rescue LoadError
  gem 'nakajima-acts_as_fu', '>= 0.0.5'
  require 'acts_as_fu'
end

require 'validatious-on-rails'

# TODO: Should extend Rails validators with this - to test respond_to.
module ActiveRecord
  module Validations
    module ClassMethods
      def validates_craziness_of(*args)
        #...
      end
    end
  end
end

# Reflected_validations already freezed...ned to find a workaround.
# reflected_validatons = ActiveRecordExtensions::ValidationReflection.reflected_validations
# stub(ActiveRecordExtensions::ValidationReflection).reflected_validations {reflected_validatons + [:validates_craziness_of]}

build_model :bogus_items do
  string :url
  string :name
  string :email
  
  text    :body
  integer :variant
  boolean :signed
  
  validates_presence_of :name, :body, :variant
  validates_confirmation_of :name
  validates_acceptance_of :signed
  validates_format_of :url,
    :with => /^(http|https|ftp):\/\/(([A-Z0-9][A-Z0-9_-]*)(\.[A-Z0-9][A-Z0-9_-]*)+)(:(\d+))?\/?/i,
    :name => 'url', :message => 'Invalid URL.'
  validates_inclusion_of :variant, :in => (1..5).to_a
  validates_exclusion_of :variant, :in => (6..10).to_a
  
  # TODO: Test: If this is a validator makro, then it should not cause any issues.
  validates_craziness_of :name
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
