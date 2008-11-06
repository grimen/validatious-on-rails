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
require 'test/unit'

begin
  require File.dirname(__FILE__) + '/../../../../config/environment'
rescue LoadError
  require 'rubygems'
  gem 'activerecord'
  gem 'actionpack'
  require 'active_record'
  require 'action_controller'
end

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.configurations = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.establish_connection(ENV['DB'] || 'mysql')

load(File.dirname(__FILE__) + '/schema.rb')
