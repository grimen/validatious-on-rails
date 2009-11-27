# encoding: utf-8
#
# This file loads up the in-memory database needed to run the tests, and adds a few
# convenience methods.
#

def smart_require(lib_name, gem_name, gem_version = '>= 0.0.0')
  begin
    require lib_name
  rescue LoadError
    gem gem_name, gem_version
    require lib_name
  end
end

begin
  require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. .. config environment]))
rescue LoadError
  require 'rubygems'
  
  smart_require 'test/unit', 'test-unit', '= 1.2.3'
  smart_require 'active_record', 'activerecord', '>= 1.2.3'
  smart_require 'action_controller', 'actionpack', '>= 1.2.3'
  smart_require 'action_view', 'actionpack', '>= 1.2.3'
  smart_require 'active_support', 'activesupport', '>= 1.2.3'
  smart_require 'sqlite3', 'sqlite3-ruby', '>= 1.2.0'
end

smart_require 'redgreen', 'redgreen', '>= 0.10.4'
smart_require 'context', 'context', '>= 0.5.5'
smart_require 'rr', 'rr', '>= 0.10.0'
smart_require 'acts_as_fu', 'acts_as_fu', '>= 0.0.5'

extend RR::Adapters::RRMethods

require 'validatious-on-rails'

require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. app controllers validates_controller]))
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. config routes]))

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
  string :file_path
  string :dummie

  text    :body
  integer :variant
  boolean :signed

  string :field_with_defaults
  string :field_with_client_side_validations
  string :field_without_client_side_validations

  validates_presence_of :name, :body, :variant, :file_path, :dummie
  validates_uniqueness_of :name
  validates_uniqueness_of :name # test dupplication (that should be ignored)
  validates_confirmation_of :name
  validates_acceptance_of :signed, :accept => true
  validates_format_of :url,
    :with => /^(http|https|ftp):\/\/(([A-Z0-9][A-Z0-9_-]*)(\.[A-Z0-9][A-Z0-9_-]*)+)(:(\d+))?\/?/i,
    :name => 'url', :message => 'Invalid URL.'
  validates_inclusion_of :variant, :in => (1..5).to_a
  validates_exclusion_of :variant, :in => (6..10).to_a
  validates_length_of :url, :minimum => 10 

  validates_presence_of :field_with_defaults
  validates_presence_of :field_with_client_side_validations, :client_side => true
  validates_presence_of :field_without_client_side_validations, :client_side => false

  # TODO: Test: If this is a validator makro, then it should not cause any issues.
  validates_craziness_of :name
end

#
# ValidationReflection seems to expect RAILS_ROOT to be defined, but it's not
# if it's tested outside of a Rails project. So, just set it to something random.
#
RAILS_ROOT = File.join(File.dirname(__FILE__)) unless defined?(RAILS_ROOT)

# To show debug messages in test output, set this to true.
#
::ValidatiousOnRails.verbose = false

#
# Log file for testing only.
#
ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), 'debug.log'))

module Test::Unit::Assertions

  #
  # Assert that a piece of HTML includes the class name.
  #
  def assert_has_class(class_name, html, message = nil)
    # Might need to consider this...but works a bit better.
    classes = html.scan(/class="([^"]*)"/).collect { |c| c.to_s.split(' ') }.flatten
    full_message = build_message(message, "<?>\nexpected to include class(es) <?>.\n", html, class_name)

    assert_block(full_message) do
      class_name.split(' ').all? { |cname| classes.include?(cname) }
    end
  end

end
