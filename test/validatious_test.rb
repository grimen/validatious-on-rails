require File.dirname(__FILE__) + '/../lib/validatious.rb'
require 'test_helper.rb'

class ValidatiousTest < Test::Unit::TestCase
  include ActionView::Helpers::FormHelper

  def test_acceptance_of
  end

  def test_associated
  end

  def test_confirmation_of
  end

  def test_exclusion_of
  end

  def test_format_of
    pattern = /^(http|https|ftp):\/\/(([A-Z0-9][A-Z0-9_-]*)(\.[A-Z0-9][A-Z0-9_-]*)+)(:(\d+))?\/?/i
    validation = Validatious::RailsValidation.format_of(validation(:validates_format_of, :with => pattern, :name => "email"))
    assert_equal "email", validation[:class_name]
  end

  def test_inclusion_of
  end

  def test_length_of_with_in
    validation = Validatious::RailsValidation.length_of(validation(:validates_length_of, :in => 1..10))
    assert_equal "min-length_1 max-length_10", validation[:class_name]

    validation = Validatious::RailsValidation.length_of(validation(:validates_length_of, :in => 1...10))
    assert_equal "min-length_1 max-length_9", validation[:class_name]
  end

  def test_length_of_with_within
    validation = Validatious::RailsValidation.length_of(validation(:validates_length_of, :within => 1..10))
    assert_equal "min-length_1 max-length_10", validation[:class_name]

    validation = Validatious::RailsValidation.length_of(validation(:validates_length_of, :within => 1...10))
    assert_equal "min-length_1 max-length_9", validation[:class_name]
  end

  def test_length_of_with_minimum
    validation = Validatious::RailsValidation.length_of(validation(:validates_length_of, :minimum => 1))
    assert_equal "min-length_1", validation[:class_name]
  end

  def test_length_of_with_maximum
    validation = Validatious::RailsValidation.length_of(validation(:validates_length_of, :maximum => 1))
    assert_equal " max-length_1", validation[:class_name]
  end

  def test_length_of_with_min_and_max
    validation = Validatious::RailsValidation.length_of(validation(:validates_length_of, :minimum => 1, :maximum => 3))
    assert_equal "min-length_1 max-length_3", validation[:class_name]
  end

  def test_numericality_of
    validation = Validatious::RailsValidation.numericality_of(validation(:validates_numericality_of))
    assert_equal "numeric", validation[:class_name]
  end

  def test_presence_of
    validation = Validatious::RailsValidation.presence_of(validation(:validates_presence_of))
    assert_equal "required", validation[:class_name]
  end

  def test_uniqueness_of
  end

  #
  # Simulate a validation
  #
  def validation(macro, options = {})
    ActiveRecord::Reflection::MacroReflection.new(macro, :name, options, nil)
  end
end

