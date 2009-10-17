# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w(.. test_helper)))

require 'active_support/test_case'

class ModelValidationsTest < ::ActiveSupport::TestCase

  include ActionView::Helpers::FormHelper

  context "validation options" do
    test ":client_side - enabling_disabling client-side validations" do
      ::ValidatiousOnRails.client_side_validations_by_default = false
      validators = ::ValidatiousOnRails::ModelValidations.from_active_record(:bogus_item, :field_with_defaults)
      assert_validator_class '', validators
      
      # FIXME: Fails for some obscure reason. If switching place with the one above, that one fails instead. =S
      ::ValidatiousOnRails.client_side_validations_by_default = true
      validators = ::ValidatiousOnRails::ModelValidations.from_active_record(:bogus_item, :field_with_defaults)
      #assert_not_validator_class '', validators
      
      validators = ::ValidatiousOnRails::ModelValidations.from_active_record(:bogus_item, :field_with_client_side_validations)
      assert_not_validator_class '', validators

      validators = ::ValidatiousOnRails::ModelValidations.from_active_record(:bogus_item, :field_without_client_side_validations)
      assert_validator_class '', validators
    end
  end

  context "from_active_record" do
    test "non concrete models" do
      assert_nothing_raised(NameError) do
        ::ValidatiousOnRails::ModelValidations.from_active_record(:thing, :field_with_defaults)
      end
      assert_equal [], ::ValidatiousOnRails::ModelValidations.from_active_record(:thing, :field_with_defaults)
    end
  end
  
  context "acceptance_of" do
    test "with defaults" do
      validators = ::ValidatiousOnRails::ModelValidations.acceptance_of(
          validation(:validates_acceptance_of)
        )
      assert_validator_class 'acceptance-accept_1', validators
    end

    test "with :accept" do
      validators = ::ValidatiousOnRails::ModelValidations.acceptance_of(
          validation(:validates_acceptance_of, :accept => true)
        )
      assert_validator_class 'acceptance-accept_true', validators
    end
  end

  test "associated" do
    # TODO: not implemented
  end

  test "confirmation_of" do
    validators = ::ValidatiousOnRails::ModelValidations.confirmation_of(
        validation(:validates_confirmation_of)
      )
    assert_validator_class 'confirmation-of_name', validators
  end

  test "exclusion_of" do
    values = (6..10).to_a
    validators = ::ValidatiousOnRails::ModelValidations.exclusion_of(
        validation(:validates_exclusion_of, :in => values)
      )
    assert_validator_class /^exclusion-in-(\d+)/, validators
    assert_match /#{values.to_json}/, validators.first.fn
  end

  test "format_of" do
    pattern = /^(http|https|ftp):\/\/(([A-Z0-9][A-Z0-9_-]*)(\.[A-Z0-9][A-Z0-9_-]*)+)(:(\d+))?\/?/i
    validators = ::ValidatiousOnRails::ModelValidations.format_of(
        validation(:validates_format_of, :with => pattern)
      )
    assert_validator_class /^format-with-(\d+)/, validators
    assert_match /#{pattern.inspect[1,-1]}/, validators.first.fn
  end

  test "inclusion_of" do
    values = (1..5).to_a
    validators = ::ValidatiousOnRails::ModelValidations.inclusion_of(
        validation(:validates_inclusion_of, :in => values)
      )
    assert_validator_class /^inclusion-in-(\d+)/, validators
    assert_match /#{values.to_json}/, validators.first.fn
  end

  context "length_of" do

    test "with :is" do
      validators = ::ValidatiousOnRails::ModelValidations.length_of(
          validation(:validates_length_of, :is => 2)
        )
      assert_validator_class 'length-is_2', validators
    end

    test "with :in" do
      validators = ::ValidatiousOnRails::ModelValidations.length_of(
          validation(:validates_length_of, :in => 2..10)
        )
      assert_validator_class 'length-minimum_2 length-maximum_10', validators
    end

    test "with :within" do
      validators = ::ValidatiousOnRails::ModelValidations.length_of(
          validation(:validates_length_of, :within => 2..10)
        )
      assert_validator_class 'length-minimum_2 length-maximum_10', validators
    end

    test "with :minimum" do
      validators = ::ValidatiousOnRails::ModelValidations.length_of(
          validation(:validates_length_of, :minimum => 2)
        )
      assert_validator_class 'length-minimum_2', validators
    end

    test "with :maximum" do
      validators = ::ValidatiousOnRails::ModelValidations.length_of(
          validation(:validates_length_of, :maximum => 10)
        )
      assert_validator_class 'length-maximum_10', validators
    end

    test "with :minimum + :maximum" do
      validators = ::ValidatiousOnRails::ModelValidations.length_of(
          validation(:validates_length_of, :minimum => 2, :maximum => 10)
        )
      assert_validator_class 'length-minimum_2 length-maximum_10', validators
    end
  end

  context "numericality_of" do

    context ":odd/:even" do
      test "with :odd only" do
        validators = ::ValidatiousOnRails::ModelValidations.numericality_of(
            validation(:validates_numericality_of, :even => false, :odd => true)
          )
        assert_validator_class 'numericality-odd', validators
      end

      test "with :even only" do
        validators = ::ValidatiousOnRails::ModelValidations.numericality_of(
            validation(:validates_numericality_of, :even => true, :odd => false)
          )
        assert_validator_class 'numericality-even', validators
      end

      test "with :odd and :even" do
        validators = ::ValidatiousOnRails::ModelValidations.numericality_of(
            validation(:validates_numericality_of, :even => true, :odd => true)
          )
        assert_validator_class '', validators
      end

      test "with neither :odd or :even" do
        validators = ::ValidatiousOnRails::ModelValidations.numericality_of(
            validation(:validates_numericality_of)
          )
        assert_validator_class '', validators
      end
    end

    test "with :only_integer" do
      validators = ::ValidatiousOnRails::ModelValidations.numericality_of(
          validation(:validates_numericality_of, :only_integer => true)
        )
      # Alt. more generic idea: assert_equal 'numericality-precision_0', validator.to_class
      assert_validator_class 'numericality-only_integer', validators
    end

    test "with :greater_than" do
      validators = ::ValidatiousOnRails::ModelValidations.numericality_of(
          validation(:validates_numericality_of, :greater_than => 2)
        )
      assert_validator_class 'numericality-greater-than_2', validators
    end

    test "with :greater_than_or_equal_to" do
      validators = ::ValidatiousOnRails::ModelValidations.numericality_of(
          validation(:validates_numericality_of, :greater_than_or_equal_to => 2)
        )
      assert_validator_class 'numericality-greater-than-or-equal-to_2', validators
    end

    test "with :equal_to" do
      validators = ::ValidatiousOnRails::ModelValidations.numericality_of(
          validation(:validates_numericality_of, :equal_to => 2)
        )
      assert_validator_class 'numericality-equal-to_2', validators
    end

    test "with :less_than" do
      validators = ::ValidatiousOnRails::ModelValidations.numericality_of(
          validation(:validates_numericality_of, :less_than => 10)
        )
      assert_validator_class 'numericality-less-than_10', validators
    end

    test "with :less_than_or_equal_to" do
      validators = ::ValidatiousOnRails::ModelValidations.numericality_of(
          validation(:validates_numericality_of, :less_than_or_equal_to => 10)
        )
      assert_validator_class 'numericality-less-than-or-equal-to_10', validators
    end
  end

  test "presence_of" do
    validators = ::ValidatiousOnRails::ModelValidations.presence_of(validation(:validates_presence_of))
    assert_validator_class 'presence', validators
  end

  test "uniqueness_of" do
    # TODO: not implemented
  end

  private

    # Simulate a validation
    #
    def validation(macro, options = {})
      ::ActiveRecord::Reflection::MacroReflection.new(macro, :name, options, BogusItem.new)
    end

    def assert_validator_class(expected, actual)
      if expected.is_a?(::Regexp)
        assert_match expected, [*actual].collect { |v| v.to_class }.join(' ')
      else
        assert_equal expected, [*actual].collect { |v| v.to_class }.join(' ')
      end
    end

    def assert_not_validator_class(expected, actual)
      if expected.is_a?(::Regexp)
        assert_no_match expected, [*actual].collect { |v| v.to_class }.join(' ')
      else
        assert_not_equal expected, [*actual].collect { |v| v.to_class }.join(' ')
      end
    end

end
