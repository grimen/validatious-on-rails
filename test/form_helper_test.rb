require File.join(File.dirname(__FILE__), 'test_helper')

class BogusItem < ActiveRecord::Base
  validates_presence_of :name
  validates_format_of :url, :with => /^(http|https|ftp):\/\/(([A-Z0-9][A-Z0-9_-]*)(\.[A-Z0-9][A-Z0-9_-]*)+)(:(\d+))?\/?/i, :name => "url"
end

module Test::Unit::Assertions
  #
  # Assert that a piece of HTML includes the class name
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
end
