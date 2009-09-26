require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

module Test::Unit::Assertions

  #
  # Assert that a piece of HTML includes the class name.
  #
  def assert_has_class(class_name, html, message = nil)
    classes = /class="([^"]*)"/.match(html)[1].split(" ")
    full_message = build_message(message, "<?>\nexpected to include class(es) <?>.\n", html, class_name)

    assert_block(full_message) do
      class_name.split(" ").all? { |cname| classes.include?(cname) }
    end
  end

end

class FormHelperTest < Test::Unit::TestCase

  include ActionView::Helpers::FormHelper

  def test_required_text_field
    assert_has_class "required", text_field(:bogus_item, :name)
    assert_has_class "required text", text_field(:bogus_item, :name, :class => "text")
  end

  def test_required_password_field
    assert_has_class "required", password_field(:bogus_item, :name)
    assert_has_class "required text", password_field(:bogus_item, :name, :class => "text")
  end

  def test_required_text_area
    assert_has_class "required", text_field(:bogus_item, :body)
    assert_has_class "required text", text_field(:bogus_item, :body, :class => "text")
  end

  def test_required_check_box # a.k.a. "acceptance required"
    assert_has_class "required", text_field(:bogus_item, :signed)
    assert_has_class "required boolean", text_field(:bogus_item, :signed, :class => "boolean")
  end

  def test_required_radio_button
    # TODO
  end

  def test_normal_label
    assert_equal "<label for=\"bogus_item_name\">Name</label>", label(:bogus_item, :name)
  end

  def test_label_with_title
    assert_equal "<label for=\"bogus_item_name\" title=\"craaazy\">Name</label>",
                 label(:bogus_item, :name, nil, :title => "craaazy")
  end

  def test_label_without_title
    assert_equal "<label for=\"bogus_item_name\" title=\"Name\">Your name</label>",
                 label(:bogus_item, :name, "Your name")
  end
  
end
