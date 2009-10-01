# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w(.. .. test_helper)))

require 'active_support/test_case'

class ValidatorTest < ::ActiveSupport::TestCase
  
  def setup
    @empty_validator = ValidatiousOnRails::Validatious::Validator.new('dummie')
    @custom_validator = returning ValidatiousOnRails::Validatious::Validator.new('dummie') do |v|
      v.message = 'Fail, fail, fail!'
      v.params = ['some', 'params']
      v.aliases = ['some', 'aliases']
      v.accept_empty = false
      v.fn = "return false;"
    end
  end
  
  test "creating an empty validator - and generate valid v2.Validator (using #to_s)" do
    assert_equal 'dummie', @empty_validator.name
    assert_equal '', @empty_validator.message
    assert_equal ([]), @empty_validator.params
    assert_equal ([]), @empty_validator.aliases
    assert_equal true, @empty_validator.accept_empty
    assert_equal "function(field, value, params) {return true;}", @empty_validator.fn.gsub(/\n/, '')
    assert_equal '
        v2.Validator.add({
          name: "dummie",
          fn: function(field, value, params) {return true;},
          acceptEmpty: true
        });'.gsub(/[\n\s\t]/, ''), @empty_validator.to_s.gsub(/[\n\s\t]/, '')
  end
  
  test "creating a custom validator - and generate valid v2.Validator (using #to_s)" do
    assert_equal 'dummie', @custom_validator.name
    assert_equal 'Fail, fail, fail!', @custom_validator.message
    assert_equal (["some", "params"]), @custom_validator.params
    assert_equal (["some", "aliases"]), @custom_validator.aliases
    assert_equal false, @custom_validator.accept_empty
    assert_equal "function(field, value, params) {return false;}", @custom_validator.fn.gsub(/\n/, '')
    assert_equal '
        v2.Validator.add({
          aliases: ["some", "aliases"],
          message: "Fail, fail, fail!",
          name: "dummie",
          fn: function(field, value, params) {return false;},
          acceptEmpty: false,
          params: ["some", "params"]
        });'.gsub(/[\n\s\t]/, ''), @custom_validator.to_s.gsub(/[\n\s\t]/, '')
  end
  
end