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
    validation = ValidatiousOnRails::ModelValidations.exclusion_of(
        validation(:validates_exclusion_of, :in => values)
      )
    assert_match /^exclusion-in-(\d+)/, validation[:class]
    assert_match /#{values.to_json}/, validation[:validator].fn
  end

  test "format_of" do
    pattern = /^(http|https|ftp):\/\/(([A-Z0-9][A-Z0-9_-]*)(\.[A-Z0-9][A-Z0-9_-]*)+)(:(\d+))?\/?/i
    validation = ValidatiousOnRails::ModelValidations.format_of(
        validation(:validates_format_of, :with => pattern)
      )
    assert_match /^format-with-(\d+)/, validation[:class]
    assert_match /#{pattern.inspect[1,-1]}/, validation[:validator].fn
  end

  test "inclusion_of" do
    values = (1..5).to_a
    validation = ValidatiousOnRails::ModelValidations.inclusion_of(
        validation(:validates_inclusion_of, :in => values)
      )
    assert_match /^inclusion-in-(\d+)/, validation[:class]
    assert_match /#{values.to_json}/, validation[:validator].fn
  end

  context "length_of" do

    test "with :is" do
      validation = ValidatiousOnRails::ModelValidations.length_of(validation(:validates_length_of, :is => 2))
      assert_equal 'length-is_2', validation[:class]
    end

    test "with :in" do
      validation = ValidatiousOnRails::ModelValidations.length_of(validation(:validates_length_of, :in => 2..10))
      assert_equal 'length-minimum_2 length-maximum_10', validation[:class]
    end

    test "with :within" do
      validation = ValidatiousOnRails::ModelValidations.length_of(validation(:validates_length_of, :within => 2..10))
      assert_equal 'length-minimum_2 length-maximum_10', validation[:class]
    end

    test "with :minimum" do
      validation = ValidatiousOnRails::ModelValidations.length_of(validation(:validates_length_of, :minimum => 2))
      assert_equal 'length-minimum_2', validation[:class]
    end

    test "with :maximum" do
      validation = ValidatiousOnRails::ModelValidations.length_of(validation(:validates_length_of, :maximum => 10))
      assert_equal 'length-maximum_10', validation[:class]
    end

    test "with :minimum + :maximum" do
      validation = ValidatiousOnRails::ModelValidations.length_of(validation(:validates_length_of, :minimum => 2, :maximum => 10))
      assert_equal 'length-minimum_2 length-maximum_10', validation[:class]
    end
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
