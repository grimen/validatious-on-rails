# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w(.. test_helper)))

require 'active_support/test_case'

class ModelValidationsTest < ::ActiveSupport::TestCase

  include ::ActionView::Helpers::FormHelper
  include ::ValidatiousOnRails
  
  context "validation options" do
    test ":client_side - enabling_disabling client-side validations" do
      ::ValidatiousOnRails.client_side_validations_by_default = false
      validators = ModelValidations.for_class_method(:bogus_item, :field_with_defaults)
      assert_validator_class '', validators
      
      # FIXME: Fails for some obscure reason. If switching place with the one above, that one fails instead. =S
      ::ValidatiousOnRails.client_side_validations_by_default = true
      validators = ModelValidations.for_class_method(:bogus_item, :field_with_defaults)
      #assert_not_validator_class '', validators
      
      validators = ModelValidations.for_class_method(:bogus_item, :field_with_client_side_validations)
      assert_not_validator_class '', validators

      validators = ModelValidations.for_class_method(:bogus_item, :field_without_client_side_validations)
      assert_validator_class '', validators
    end
  end

  context "from_active_record" do
    test "non concrete models" do
      assert_nothing_raised(NameError) do
        ModelValidations.for_class_method(:thing, :field_with_defaults)
      end
      assert_equal [], ModelValidations.for_class_method(:thing, :field_with_defaults)
    end
  end
  
  context "acceptance_of" do
    test "with defaults" do
      validators = ModelValidations.for_validation(:acceptance_of,
          validation(:validates_acceptance_of)
        )
      assert_validator_class 'acceptance-of-accept_1_false', validators
    end

    test "with :accept" do
      validators = ModelValidations.for_validation(:acceptance_of,
          validation(:validates_acceptance_of, :accept => true)
        )
      assert_validator_class 'acceptance-of-accept_true_false', validators
    end
  end

  test "associated" do
    # TODO: not implemented
  end

  test "confirmation_of" do
    validators = ModelValidations.for_validation(:confirmation_of,
        validation(:validates_confirmation_of)
      )
    assert_validator_class 'confirmation-of_name', validators
  end

  test "exclusion_of" do
    values = (6..10).to_a
    validators = ModelValidations.for_validation(:exclusion_of,
        validation(:validates_exclusion_of, :in => values)
      )
    assert_validator_class /^exclusion-of-in_(\d+)/, validators
    assert_match /#{values.to_json}/, [*validators].first.fn
  end

  test "format_of" do
    pattern = /^(http|https|ftp):\/\/(([A-Z0-9][A-Z0-9_-]*)(\.[A-Z0-9][A-Z0-9_-]*)+)(:(\d+))?\/?/i
    validators = ModelValidations.for_validation(:format_of,
        validation(:validates_format_of, :with => pattern)
      )
    assert_validator_class /^format-of-with_(\d+)_false_false/, validators
    assert_match /#{pattern.inspect[1,-1]}/, [*validators].first.fn
  end

  test "inclusion_of" do
    values = (1..5).to_a
    validators = ModelValidations.for_validation(:inclusion_of,
        validation(:validates_inclusion_of, :in => values)
      )
    assert_validator_class /^inclusion-of-in_(\d+)_false_false/, validators
    assert_match /#{values.to_json}/, [*validators].first.fn
  end

  context "length_of" do

    test "with :is" do
      validators = ModelValidations.for_validation(:length_of,
          validation(:validates_length_of, :is => 2)
        )
      assert_validator_class 'length-of-is_2_false_false', validators
    end

    test "with :in" do
      validators = ModelValidations.for_validation(:length_of,
          validation(:validates_length_of, :in => 2..10)
        )
      assert_validator_class 'length-of-minimum_2_false_false length-of-maximum_10_false_false', validators
    end

    test "with :within" do
      validators = ModelValidations.for_validation(:length_of,
          validation(:validates_length_of, :within => 2..10)
        )
      assert_validator_class 'length-of-minimum_2_false_false length-of-maximum_10_false_false', validators
    end

    test "with :minimum" do
      validators = ModelValidations.for_validation(:length_of,
          validation(:validates_length_of, :minimum => 2)
        )
      assert_validator_class 'length-of-minimum_2_false_false', validators
    end

    test "with :maximum" do
      validators = ModelValidations.for_validation(:length_of,
          validation(:validates_length_of, :maximum => 10)
        )
      assert_validator_class 'length-of-maximum_10_false_false', validators
    end

    test "with :minimum + :maximum" do
      validators = ModelValidations.for_validation(:length_of,
          validation(:validates_length_of, :minimum => 2, :maximum => 10)
        )
      assert_validator_class 'length-of-minimum_2_false_false length-of-maximum_10_false_false', validators
    end
  end

  context "numericality_of" do

    context ":odd/:even" do
      test "with :odd only" do
        validators = ModelValidations.for_validation(:numericality_of,
            validation(:validates_numericality_of, :even => false, :odd => true)
          )
        assert_validator_class 'numericality-of-odd_false', validators
      end

      test "with :even only" do
        validators = ModelValidations.for_validation(:numericality_of,
            validation(:validates_numericality_of, :even => true, :odd => false)
          )
        assert_validator_class 'numericality-of-even_false', validators
      end

      # test "with :odd and :even" do
      #   validators = ModelValidations.for_validation(:numericality_of,
      #       validation(:validates_numericality_of, :even => true, :odd => true)
      #     )
      #   assert_validator_class 'numericality-of_false_false', validators
      # end
      # 
      # test "with neither :odd or :even" do
      #   validators = ModelValidations.for_validation(:numericality_of,
      #       validation(:validates_numericality_of)
      #     )
      #   assert_validator_class '', validators
      # end
    end

    test "with :only_integer" do
      validators = ModelValidations.for_validation(:numericality_of,
          validation(:validates_numericality_of, :only_integer => true)
        )
      # Alt. more generic idea: assert_equal 'numericality-precision_0', validator.to_class
      assert_validator_class 'numericality-of-only-integer_false', validators
    end

    test "with :greater_than" do
      validators = ModelValidations.for_validation(:numericality_of,
          validation(:validates_numericality_of, :greater_than => 2)
        )
      assert_validator_class 'numericality-of-greater-than_2_false', validators
    end

    test "with :greater_than_or_equal_to" do
      validators = ModelValidations.for_validation(:numericality_of,
          validation(:validates_numericality_of, :greater_than_or_equal_to => 2)
        )
      assert_validator_class 'numericality-of-greater-than-or-equal-to_2_false', validators
    end

    test "with :equal_to" do
      validators = ModelValidations.for_validation(:numericality_of,
          validation(:validates_numericality_of, :equal_to => 2)
        )
      assert_validator_class 'numericality-of-equal-to_2_false', validators
    end

    test "with :less_than" do
      validators = ModelValidations.for_validation(:numericality_of,
          validation(:validates_numericality_of, :less_than => 10)
        )
      assert_validator_class 'numericality-of-less-than_10_false', validators
    end

    test "with :less_than_or_equal_to" do
      validators = ModelValidations.for_validation(:numericality_of,
          validation(:validates_numericality_of, :less_than_or_equal_to => 10)
        )
      assert_validator_class 'numericality-of-less-than-or-equal-to_10_false', validators
    end
  end

  test "presence_of" do
    validators = ModelValidations.for_validation(:presence_of, validation(:validates_presence_of))
    assert_validator_class 'presence-of', validators
  end

  test "uniqueness_of" do
    validators = ModelValidations.for_validation(:uniqueness_of, validation(:validates_uniqueness_of))
    assert_validator_class 'uniqueness-of-remote_false_false', validators
    # Ignore duplicates (Note: defined two times in TestHelper).
    assert_equal 1, [*validators].collect { |v| v.to_class.split(' ') }.flatten.select { |c| c == 'uniqueness-of-remote_false_false'}.size
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
