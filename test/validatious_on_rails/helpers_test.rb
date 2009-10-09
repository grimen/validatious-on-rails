# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w(.. test_helper)))

require 'action_view/test_case'

class HelpersTest < ::ActionView::TestCase

  include ActionView::Helpers::FormHelper

  attr_accessor :output_buffer

  before do
    @output_buffer ||= ''
  end

  context "helpers" do
    context "custom_validatious_validators" do

      test "should not output custom validators if there are none" do
        helper_output = javascript_for_validatious
        assert_equal '', helper_output.to_s
      end

      test "should output custom validators if they exists" do
        form_for(::BogusItem.new, :url => '/bogus_items') do |f|
          concat f.text_field(:url)
        end

        # FIXME: Not sure how to test content_for-helpers...returns nil.
        concat javascript_for_validatious

        # In parts...
        assert_match /<script.+>.*v2.Validator.*<\/script>/, output_buffer
        assert_match /<script.*id="custom_validators".*>/, output_buffer
        assert_match /<script.*type="text\/javascript".*>/, output_buffer
      end

    end
  end

  private

    def protect_against_forgery?
      false
    end

end