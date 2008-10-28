require File.dirname(__FILE__) + '/../lib/validatious.rb'
#require 'test/unit'
#require 'rubygems'
#require 'action_view/helpers/form_helper.rb'
#require 'action_view/helpers/tag_helper.rb'
#require 'active_record/reflection.rb'
require '../../../test/test_helper.rb'

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
  end

  def test_inclusion_of
  end

  def test_length_of_with_in
    validation = Validatious::Validation.length_of(validation(:validates_length_of, :in => 1..10))
    assert_equal "min-length_1 max-length_10", validation[:class_name]

    validation = Validatious::Validation.length_of(validation(:validates_length_of, :in => 1...10))
    assert_equal "min-length_1 max-length_9", validation[:class_name]
  end

  def test_length_of_with_within
    validation = Validatious::Validation.length_of(validation(:validates_length_of, :within => 1..10))
    assert_equal "min-length_1 max-length_10", validation[:class_name]

    validation = Validatious::Validation.length_of(validation(:validates_length_of, :within => 1...10))
    assert_equal "min-length_1 max-length_9", validation[:class_name]
  end

  def test_length_of_with_minimum
    validation = Validatious::Validation.length_of(validation(:validates_length_of, :minimum => 1))
    assert_equal "min-length_1", validation[:class_name]
  end

  def test_length_of_with_maximum
    validation = Validatious::Validation.length_of(validation(:validates_length_of, :maximum => 1))
    assert_equal " max-length_1", validation[:class_name]
  end

  def test_length_of_with_min_and_max
    validation = Validatious::Validation.length_of(validation(:validates_length_of, :minimum => 1, :maximum => 3))
    assert_equal "min-length_1 max-length_3", validation[:class_name]
  end

  def test_numericality_of
  end

  def test_presence_of
    validation = Validatious::Validation.presence_of(validation(:validates_presence_of))
    assert_equal "required", validation[:class_name]
  end

  def test_uniqueness_of
  end

  def validation(macro, options = {})
    ActiveRecord::Reflection::MacroReflection.new(macro, :name, options, nil)
  end
end

