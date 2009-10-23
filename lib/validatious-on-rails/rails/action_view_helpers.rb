# encoding: utf-8
require File.join(File.dirname(__FILE__), *%w[.. helpers])
#
# Tap into the built-in form/input helpers to add validatious class names from
# model validations. Only altering the options hash is interesting - we want to set a validator class for fields,
# so the hooking of these helpers don't have to be very explicit.
#
module ActionView # :nodoc:
  module Helpers # :nodoc:
    module FormHelper # :nodoc:

      include ::ValidatiousOnRails::Helpers

      FIELD_TYPES = [:text_field, :password_field, :text_area, :file_field, :radio_button, :check_box].freeze
      FIELD_TYPES.each do |field_type|
        define_with_validatious_support(field_type)
      end

    end

    module FormOptionsHelper # :nodoc:

      include ::ValidatiousOnRails::Helpers

      FIELD_TYPES = [:time_zone_select, :select, :collection_select, :grouped_collection_select].freeze
      FIELD_TYPES.each do |field_type|
        define_with_validatious_support(field_type)
      end

    end

    module DateHelper # :nodoc:

      include ::ValidatiousOnRails::Helpers

      FIELD_TYPES = [:date_select, :datetime_select, :time_select].freeze
      FIELD_TYPES.each do |field_type|
        define_with_validatious_support(field_type)
      end

    end

  end
end
