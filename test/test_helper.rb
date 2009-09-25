#
# This file loads up the database needed to run the tests, and adds a few
# convenience methods.
#
# This file is originally by Jonathan Viney, written for the
# ActsAsTaggableOnSteroids plugin:
# http://svn.viney.net.nz/things/rails/plugins/acts_as_taggable_on_steroids/test/abstract_unit.rb
#
# Modified for validatious_on_rails by Christian Johansen
#

begin
  require File.expand_path(File.join(File.dirname(__FILE__), *%w(.. .. .. .. config environment)))
rescue LoadError
  require 'rubygems'
  gem 'test-unit', '1.2.3'
  gem 'activerecord', '>= 1.2.3'
  gem 'actionpack', '>= 1.2.3'
  require 'test/unit'
  require 'active_record'
  require 'action_controller'
end

#
# ValidationReflection seems to expect RAILS_ROOT to be defined, but it's not
# if it's tested outside of a Rails project. So, just set it to something random.
#
RAILS_ROOT = File.join(File.dirname(__FILE__)) unless defined?(RAILS_ROOT)

ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), 'debug.log'))
ActiveRecord::Base.configurations = YAML::load(IO.read(File.join(File.dirname(__FILE__), 'database.yml')))
ActiveRecord::Base.establish_connection(ENV['DB'] || 'sqlite3')

load(File.join(File.dirname(__FILE__), 'schema.rb'))

require 'validatious'
