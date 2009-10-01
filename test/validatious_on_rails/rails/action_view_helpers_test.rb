# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w(.. .. test_helper)))

module Test::Unit::Assertions

  #
  # Assert that a piece of HTML includes the class name.
  #
  def assert_has_class(class_name, html, message = nil)
    # Might need to consider this...but works a bit better.
    classes = html.scan(/class="([^"]*)"/).collect { |c| c.to_s.split(' ') }.flatten
    full_message = build_message(message, "<?>\nexpected to include class(es) <?>.\n", html, class_name)

    assert_block(full_message) do
      class_name.split(' ').all? { |cname| classes.include?(cname) }
    end
  end

end

require 'action_view/test_case'

class FormHelperTest < ::ActionView::TestCase

  include ActionView::Helpers::FormHelper

  def setup
    @bogus_item = BogusItem.new
  end
  
  test "attach custom javascript validations to layout" do
    @content_for_validatious = nil
    view_output = form_for(@bogus_item, :url => '/bogus_items') do |f|
      concat f.text_field(:url)
    end
    assert_match /v2.Validator/, @content_for_validatious
  end
  
  test "required :text_field" do
    # Using helper
    assert_has_class 'required', text_field(:bogus_item, :name)
    assert_has_class 'required text', text_field(:bogus_item, :name, :class => 'text')
    
    # Using builder
    assert_has_class 'required', form_for(@bogus_item, :url => '/bogus_items') { |f|
        concat f.text_field(:name)
      }
    assert_has_class 'required text', form_for(@bogus_item, :url => '/bogus_items') { |f|
        concat f.text_field(:name, :class => 'text')
      }
  end

  test "required :password_field" do
    # Using helper
    assert_has_class 'required', password_field(:bogus_item, :name)
    assert_has_class 'required text', password_field(:bogus_item, :name, :class => 'text')
    
    # Using builder
    assert_has_class 'required', form_for(@bogus_item, :url => '/bogus_items') { |f|
        concat f.password_field(:name)
      }
    assert_has_class 'required text', form_for(@bogus_item, :url => '/bogus_items') { |f|
        concat f.password_field(:name, :class => 'text')
      }
  end

  test "required :text_area" do
    # Using helper
    assert_has_class 'required', text_area(:bogus_item, :body)
    assert_has_class 'required text', text_area(:bogus_item, :body, :class => 'text')
    
    # Using builder
    assert_has_class 'required', form_for(@bogus_item, :url => '/bogus_items') { |f|
        concat f.text_area(:body)
      }
    assert_has_class 'required text', form_for(@bogus_item, :url => '/bogus_items') { |f|
        concat f.text_area(:body, :class => 'text')
      }
  end

  test "required :check_box" do # a.k.a. "acceptance required"
    # Using helper
    assert_has_class 'required', check_box(:bogus_item, :signed)
    assert_has_class 'required boolean', check_box(:bogus_item, :signed, :class => 'boolean')
    
    # Using builder
    assert_has_class 'required', form_for(@bogus_item, :url => '/bogus_items') { |f|
        concat f.check_box(:signed)
      }
    assert_has_class 'required boolean', form_for(@bogus_item, :url => '/bogus_items') { |f|
        concat f.check_box(:signed, :class => 'boolean')
      }
  end

  test "required :radio_button" do
    # Using helper
     assert_has_class 'required', radio_button(:bogus_item, :variant, 1)
     assert_has_class 'required bogus', radio_button(:bogus_item, :variant, 1, :class => 'bogus')
     
     assert_has_class 'required', form_for(@bogus_item, :url => '/bogus_items') { |f|
         concat f.radio_button(:variant, 1)
       }
     assert_has_class 'required bogus', form_for(@bogus_item, :url => '/bogus_items') { |f|
         concat f.radio_button(:variant, 1, :class => 'bogus')
       }
  end

  test "confirmation_of :name field" do
    # Using helper
    assert_has_class 'confirmation-of_name', text_field(:bogus_item, :name_confirmation)
    assert_has_class 'confirmation-of_name confirmation', text_field(:bogus_item, :name_confirmation, :class => "confirmation")
    
    # Using builder
    assert_has_class 'confirmation-of_name', form_for(@bogus_item, :url => '/bogus_items') { |f|
        concat f.text_field(:name_confirmation)
      }
    assert_has_class 'confirmation-of_name confirmation', form_for(@bogus_item, :url => '/bogus_items') { |f|
        concat f.text_field(:name_confirmation, :class => 'confirmation')
      }
  end

  test "format_of :url field" do
    # Using helper
    assert_has_class 'url', text_field(:bogus_item, :url)
    assert_has_class 'url some_other_class', text_field(:bogus_item, :url, :class => 'some_other_class')
    
    # Using builder
    assert_has_class 'url', form_for(@bogus_item, :url => '/bogus_items') { |f|
        concat f.text_field(:url)
      }
    assert_has_class 'url some_other_class', form_for(@bogus_item, :url => '/bogus_items') { |f|
        concat f.text_field(:url, :class => 'some_other_class')
      }
    assert_match /v2.Validator\.add\(.*\{.*name:.*"url"/, @content_for_validatious
  end
  
  test "exclusion_of :variant field" do
    # TODO
  end

  test "inclusion_of :variant field" do
    # TODO
  end

  test "regular label" do
    # Using helper
    assert_equal "<label for=\"bogus_item_name\">Name</label>", label(:bogus_item, :name)
  end

  test "label with title" do
    # Using helper
    assert_equal "<label for=\"bogus_item_name\" title=\"craaazy\">Name</label>",
                 label(:bogus_item, :name, nil, :title => "craaazy")
  end

  test "label without title" do
    # Using helper
    assert_equal "<label for=\"bogus_item_name\" title=\"Name\">Your name</label>",
                 label(:bogus_item, :name, "Your name")
  end

  private

    def protect_against_forgery?
      false
    end

end
