# encoding: utf-8
require File.join(File.dirname(__FILE__), *%w[.. helpers])
#
# Tap into the built-in form/input helpers to add validatious class names from
# model validations.
#
module ActionView # :nodoc:
  module Helpers # :nodoc:
    module FormHelper # :nodoc:

      include ::ValidatiousOnRails::Helpers

      FIELD_TYPES = [:text_field, :password_field, :text_area, :file_field, :radio_button, :check_box].freeze

      # Only altering the options hash is interesting - we want to set a validator class for fields,
      # so the hooking of these helpers don't have to be very explicit.
      #
      FIELD_TYPES.each do |field_type|
        define_with_validatious_support(field_type)
      end

      # Adds the title attribute to label tags when there is no title
      # set, and the label text is provided. The title is set to object_name.humanize
      #
      def label_with_title(object_name, method, text = nil, options = {})
        options[:title] ||= object_name.to_s.classify.constantize.human_attribute_name(method.to_s) unless text.nil?
        label_without_title(object_name, method, text, options)
      end
      alias_method_chain :label, :title

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
