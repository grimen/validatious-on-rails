# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w(.. .. test_helper)))

require 'action_view/test_case'

class FormHelperTest < ::ActionView::TestCase

  include ::ActionView::Helpers::FormHelper
  include ::ActiveSupport

  before do
    @bogus_item = BogusItem.new
  end

  context "layout" do
    test "attach custom javascript validations to layout" do
      @content_for_validatious = nil
      view_output = form_for(@bogus_item, :url => '/bogus_items') do |f|
        concat f.text_field(:url)
      end
      assert_match /v2.Validator/, @content_for_validatious
    end
  end

  context "field class names" do
    context "form helpers" do
      test ":text_field" do
        # Using helper
        assert_has_class 'presence', text_field(:bogus_item, :name, {})
        assert_has_class 'presence some_other_class', text_field(:bogus_item, :name, :class => 'some_other_class')
        # Using builder
        assert_has_class 'presence', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.text_field(:name, {})
          }
        assert_has_class 'presence text', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.text_field(:name, :class => 'text')
          }
      end

      test ":password_field" do
        # Using helper
        assert_has_class 'presence', password_field(:bogus_item, :name, {})
        assert_has_class 'presence some_other_class', password_field(:bogus_item, :name, :class => 'some_other_class')
        # Using builder
        assert_has_class 'presence', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.password_field(:name, {})
          }
        assert_has_class 'presence some_other_class', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.password_field(:name, :class => 'some_other_class')
          }
      end

      test ":text_area" do
        # Using helper
        assert_has_class 'presence', text_area(:bogus_item, :body, {})
        assert_has_class 'presence some_other_class', text_area(:bogus_item, :body, :class => 'some_other_class')
        # Using builder
        assert_has_class 'presence', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.text_area(:body, {})
          }
        assert_has_class 'presence some_other_class', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.text_area(:body, :class => 'some_other_class')
          }
      end

      test ":check_box" do # a.k.a. "acceptance required"
        # Using +helper+
        assert_has_class 'acceptance-accept_true', check_box(:bogus_item, :signed, {}, '1', '0')
        assert_has_class 'acceptance-accept_true some_other_class', check_box(:bogus_item, :signed, :class => 'some_other_class')
        # Using builder
        assert_has_class 'acceptance-accept_true', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.check_box(:signed, {})
          }
        assert_has_class 'acceptance-accept_true some_other_class', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.check_box(:signed, :class => 'some_other_class')
          }
      end

      test ":radio_button" do
        # Using helper
        assert_has_class 'presence', radio_button(:bogus_item, :variant, 1, {})
        assert_has_class 'presence some_other_class', radio_button(:bogus_item, :variant, 1, :class => 'some_other_class')
        # Using builder
        assert_has_class 'presence', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.radio_button(:variant, 1, {})
          }
        assert_has_class 'presence some_other_class', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.radio_button(:variant, 1, :class => 'some_other_class')
          }
      end
      
      test ":file_field" do
        # Using helper
        assert_has_class 'presence', file_field(:bogus_item, :file_path, {})
        assert_has_class 'presence some_other_class', file_field(:bogus_item, :file_path, :class => 'some_other_class')
        # Using builder
        assert_has_class 'presence', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.file_field(:variant, {})
          }
        assert_has_class 'presence some_other_class', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.file_field(:variant, :class => 'some_other_class')
          }
      end
    end

    context "form options fields" do
      test ":select" do
        # Using helper
        assert_has_class 'presence', select(:bogus_item, :variant, [], {}, {})
        assert_has_class 'presence some_other_class', select(:bogus_item, :variant, [], {}, :class => 'some_other_class')
        # Using builder
        assert_has_class 'presence', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.select(:variant, [], {}, {})
          }
        assert_has_class 'presence some_other_class', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.select(:variant, [], {}, :class => 'some_other_class')
          }
      end

      test ":collection_select" do
        # Using helper
        assert_has_class 'presence', collection_select(:bogus_item, :variant, [], :to_param, :to_s, {}, {})
        assert_has_class 'presence some_other_class', collection_select(:bogus_item, :variant, [], :to_param, :to_s, {}, :class => 'some_other_class')
        # Using builder
        assert_has_class 'presence', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.collection_select(:variant, [], :to_param, :to_s, {}, {})
          }
        assert_has_class 'presence some_other_class', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.collection_select(:variant, [], :to_param, :to_s, {}, :class => 'some_other_class')
          }
      end

      test ":grouped_collection_select" do
        # Using helper
        assert_has_class 'presence', grouped_collection_select(:bogus_item, :variant, [], :bogus_items, :name, :id, :name, {}, {})
        assert_has_class 'presence some_other_class', grouped_collection_select(:bogus_item, :variant, [], :bogus_items, :name, :id, :name, {}, :class => 'some_other_class')
        # Using builder
        assert_has_class 'presence', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.grouped_collection_select(:variant, [], :bogus_items, :name, :id, :name, {}, {})
          }
        assert_has_class 'presence some_other_class', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.grouped_collection_select(:variant, [], :bogus_items, :name, :id, :name, {}, :class => 'some_other_class')
          }
      end

      test ":time_zone_select" do
        # Using helper
        assert_has_class 'presence', time_zone_select(:bogus_item, :dummie, TimeZone.us_zones, {}, {})
        assert_has_class 'presence some_other_class', time_zone_select(:bogus_item, :dummie, TimeZone.us_zones, {}, :class => 'some_other_class')
        # Using builder
        assert_has_class 'presence', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.time_zone_select(:dummie, TimeZone.us_zones, {}, {})
          }
        assert_has_class 'presence some_other_class', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.time_zone_select(:dummie, TimeZone.us_zones, {}, :class => 'some_other_class')
          }
      end
    end

    context "date helper fields" do
      test ":datetime_select" do
        # Using helper
        assert_has_class 'presence', datetime_select(:bogus_item, :dummie, {}, {})
        assert_has_class 'presence some_other_class', datetime_select(:bogus_item, :dummie, {}, :class => 'some_other_class')
        # Using builder
        assert_has_class 'presence', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.datetime_select(:dummie, {}, {})
          }
        assert_has_class 'presence some_other_class', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.datetime_select(:dummie, {}, :class => 'some_other_class')
          }
      end
      
      test ":date_select" do
        # Using helper
        assert_has_class 'presence', date_select(:bogus_item, :dummie, {}, {})
        assert_has_class 'presence some_other_class', date_select(:bogus_item, :dummie, {}, :class => 'some_other_class')
        # Using builder
        assert_has_class 'presence', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.date_select(:dummie, {}, {})
          }
        assert_has_class 'presence some_other_class', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.date_select(:dummie, {}, :class => 'some_other_class')
          }
      end
      
      test ":time_select" do
        # Using helper
        assert_has_class 'presence', time_select(:bogus_item, :dummie, {}, {})
        assert_has_class 'presence some_other_class', time_select(:bogus_item, :dummie, {}, :class => 'some_other_class')
        # Using builder
        assert_has_class 'presence', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.time_select(:dummie, {}, {})
          }
        assert_has_class 'presence some_other_class', form_for(@bogus_item, :url => '/bogus_items') { |f|
            concat f.time_select(:dummie, {}, :class => 'some_other_class')
          }
      end
    end
  end

  context "validator types" do
    test "confirmation_of" do
      # Using helper
      assert_has_class 'confirmation-of_name', text_field(:bogus_item, :name_confirmation, {})
      assert_has_class 'confirmation-of_name some_other_class', text_field(:bogus_item, :name_confirmation, :class => 'some_other_class')
      # Using builder
      assert_has_class 'confirmation-of_name', form_for(@bogus_item, :url => '/bogus_items') { |f|
          concat f.text_field(:name_confirmation, {})
        }
      assert_has_class 'confirmation-of_name some_other_class', form_for(@bogus_item, :url => '/bogus_items') { |f|
          concat f.text_field(:name_confirmation, :class => 'some_other_class')
        }
    end

    test "format_of" do
      # Using helper
      assert_has_class 'url', text_field(:bogus_item, :url, {})
      assert_has_class 'url some_other_class', text_field(:bogus_item, :url, :class => 'some_other_class')
      # Using builder
      assert_has_class 'url', form_for(@bogus_item, :url => '/bogus_items') { |f|
          concat f.text_field(:url, {})
        }
      assert_has_class 'url some_other_class', form_for(@bogus_item, :url => '/bogus_items') { |f|
          concat f.text_field(:url, :class => 'some_other_class')
        }
      assert_match /v2.Validator\.add\(.*\{.*"url"/, @content_for_validatious
    end
    
    # TODO: The other validators...
  end

  private

    def protect_against_forgery?
      false
    end

end
