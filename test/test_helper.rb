ENV["RAILS_ENV"] = "test"
require 'action_view/helpers/form_helper.rb'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end
