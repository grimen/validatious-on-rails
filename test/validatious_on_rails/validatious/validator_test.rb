# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w(.. .. test_helper)))

require 'active_support/test_case'

class ValidatorTest < ::ActiveSupport::TestCase

  def setup
    @empty_validator = ValidatiousOnRails::Validatious::ClientSideValidator.new('dummie')
    @custom_validator = returning ValidatiousOnRails::Validatious::ClientSideValidator.new('dummie') do |v|
      v.message = 'Fail, fail, fail!'
      v.params = ['some', 'params']
      v.aliases = ['some', 'aliases']
      v.accept_empty = false
      v.fn = "return false;"
    end
  end

  test "creating an empty validator - and generate valid v2.Validator and class call" do
    assert_equal 'dummie', @empty_validator.name
    assert_equal '', @empty_validator.message
    assert_equal ([]), @empty_validator.params
    assert_equal ([]), @empty_validator.aliases
    assert_equal true, @empty_validator.accept_empty
    assert_equal "function(field, value, params){return true;}", @empty_validator.fn

    expected_v2_validator = 'v2.Validator.add({
      acceptEmpty: true,
      fn: function(field, value, params){return true;},
      name: "dummie"
    });'

    assert_equal @custom_validator.name, @custom_validator.to_class
    assert_equal "#{@custom_validator.name}_1_hello_2", @custom_validator.to_class(1, "hello", 2)
    assert_equal ::ValidatiousOnRails::Validatious::Validator.truncate_whitespace(expected_v2_validator), @empty_validator.to_js
  end

  test "creating a custom validator - and generate valid v2.Validator and class call" do
    assert_equal 'dummie', @custom_validator.name
    assert_equal 'Fail, fail, fail!', @custom_validator.message
    assert_equal (["some", "params"]), @custom_validator.params
    assert_equal (["some", "aliases"]), @custom_validator.aliases
    assert_equal false, @custom_validator.accept_empty
    assert_equal "function(field, value, params){return false;}", @custom_validator.fn

    expected_v2_validator = 'v2.Validator.add({
      acceptEmpty: false,
      aliases: ["some", "aliases"],
      fn: function(field, value, params){return false;},
      message: "Fail, fail, fail!",
      name: "dummie",
      params: ["some", "params"]
    });'

    assert_equal @custom_validator.name, @custom_validator.to_class
    assert_equal "#{@custom_validator.name}_1_hello_2", @custom_validator.to_class(1, "hello", 2)
    assert_equal ::ValidatiousOnRails::Validatious::Validator.truncate_whitespace(expected_v2_validator), @custom_validator.to_js
  end

  context "Message" do
    test "I18n lookup" do
      validator_klass = ::ValidatiousOnRails::Validatious::Validator
      # For some reason can't raise this in tests. =S
      # assert_raise(::I18n::MissingInterpolationArgument) {
      #    validator_klass.generate_message :key => :too_short
      #   }
      assert_nothing_raised(::I18n::MissingInterpolationArgument) {
          validator_klass.generate_message :key => :too_short, :count => '{{count}}'
        }
    end
  end
  
  context "JavaScript" do
    test "truncation of whitespace characters" do
      duck_validator = ::ValidatiousOnRails::Validatious::ClientSideValidator.new('duck')
      # Well... =)
      duck_validator.fn = %{
        var duck_says = "Quack!";
        
        if (duck_says != "Quack!") {
          return (duck_says == "Quack! Quack!");
        }
        
        return true;
      }
      compact_fn = %{function(field, value, params){var duck_says = "Quack!";if (duck_says != "Quack!"){return (duck_says == "Quack! Quack!");}return true;}}
      assert_equal(compact_fn, duck_validator.fn)
    end
  end

end