# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w(.. test_helper)))

require 'active_support/test_case'

class ModelValidationsTest < ::ActiveSupport::TestCase
  
  include ActionView::Helpers::FormHelper
  
  test "acceptance_of" do
    validation = ValidatiousOnRails::ModelValidations.acceptance_of(validation(:validates_acceptance_of))
    assert_equal 'required', validation[:class]
  end
  
  test "associated" do
    # TODO: not implemented
  end
  
  test "confirmation_of" do
    validation = ValidatiousOnRails::ModelValidations.confirmation_of(validation(:validates_confirmation_of))
    assert_equal 'confirmation-of_name', validation[:class]
  end
  
  test "exclusion_of" do
    values = (6..10).to_a
    validation = ValidatiousOnRails::ModelValidations.exclusion_of(validation(:validates_exclusion_of,
      :in => values))
    assert_match /^exclusion-in-(\d+)/, validation[:class]
    assert_match /#{values.to_json}/, validation[:validator].fn
  end
  
  test "format_of" do
    pattern = /^(http|https|ftp):\/\/(([A-Z0-9][A-Z0-9_-]*)(\.[A-Z0-9][A-Z0-9_-]*)+)(:(\d+))?\/?/i
    validation = ValidatiousOnRails::ModelValidations.format_of(validation(:validates_format_of,
      :with => pattern, :name => 'url'))
    assert_equal 'url', validation[:class]
    assert_match /#{pattern.inspect[1,-1]}/, validation[:validator].fn
  end
  
  test "inclusion_of" do
    values = (1..5).to_a
    validation = ValidatiousOnRails::ModelValidations.inclusion_of(validation(:validates_inclusion_of,
      :in => values))
    assert_match /^inclusion-in-(\d+)/, validation[:class]
    assert_match /#{values.to_json}/, validation[:validator].fn
  end
  
  test "length_of_with_in" do
    validation = ValidatiousOnRails::ModelValidations.length_of(validation(:validates_length_of, :in => 1..10))
    assert_equal 'min-length_1 max-length_10', validation[:class]
  
    validation = ValidatiousOnRails::ModelValidations.length_of(validation(:validates_length_of, :in => 1...10))
    assert_equal 'min-length_1 max-length_9', validation[:class]
  end
  
  test "length_of_with_within" do
    validation = ValidatiousOnRails::ModelValidations.length_of(validation(:validates_length_of, :within => 1..10))
    assert_equal 'min-length_1 max-length_10', validation[:class]
  
    validation = ValidatiousOnRails::ModelValidations.length_of(validation(:validates_length_of, :within => 1...10))
    assert_equal 'min-length_1 max-length_9', validation[:class]
  end
  
  test "length_of_with_minimum" do
    validation = ValidatiousOnRails::ModelValidations.length_of(validation(:validates_length_of, :minimum => 1))
    assert_equal 'min-length_1', validation[:class]
  end
  
  test "length_of_with_maximum" do
    validation = ValidatiousOnRails::ModelValidations.length_of(validation(:validates_length_of, :maximum => 1))
    assert_equal 'max-length_1', validation[:class]
  end
  
  test "length_of_with_min_and_max" do
    validation = ValidatiousOnRails::ModelValidations.length_of(validation(:validates_length_of, :minimum => 1, :maximum => 3))
    assert_equal 'min-length_1 max-length_3', validation[:class]
  end
  
  test "numericality_of" do
    validation = ValidatiousOnRails::ModelValidations.numericality_of(validation(:validates_numericality_of))
    assert_equal 'numeric', validation[:class]
  end
  
  test "presence_of" do
    validation = ValidatiousOnRails::ModelValidations.presence_of(validation(:validates_presence_of))
    assert_equal 'required', validation[:class]
  end
  
  test "uniqueness_of" do
    # TODO: not implemented
  end
  
  private
    
    # Simulate a validation
    #
    def validation(macro, options = {})
      ActiveRecord::Reflection::MacroReflection.new(macro, :name, options, BogusItem.new)
    end
    
end
