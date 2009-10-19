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
        define_method :"#{field_type}_with_validation" do |*args|
          args, tail = ::ValidatiousOnRails::Helpers.extract_args!(*args)
          options = self.attach_validator_for(args.first, args.second, args.extract_options!)
          self.send :"#{field_type}_without_validation", *((args << options) + tail)
        end
        alias_method_chain field_type, :validation
      end

      # Adds the title attribute to label tags when there is no title
      # set, and the label text is provided. The title is set to object_name.humanize
      #
      def label_with_title(object_name, method, text = nil, options = {})
        options[:title] ||= method.to_s.humanize unless text.nil?
        label_without_title(object_name, method, text, options)
      end
      alias_method_chain :label, :title

    end

    module FormOptionsHelper

      include ::ValidatiousOnRails::Helpers

      FIELD_TYPES = [:time_zone_select, :select, :collection_select, :grouped_collection_select].freeze

      FIELD_TYPES.each do |field_type|
        define_method :"#{field_type}_with_validation" do |*args|
          args, tail = ::ValidatiousOnRails::Helpers.extract_args!(*args)
          options = self.attach_validator_for(args.first, args.second, args.extract_options!)
          self.send :"#{field_type}_without_validation", *((args << options) + tail)
        end
        alias_method_chain field_type, :validation
      end

    end

    module DateHelper

      include ::ValidatiousOnRails::Helpers

      FIELD_TYPES = [:date_select, :datetime_select, :time_select].freeze

      FIELD_TYPES.each do |field_type|
        define_method :"#{field_type}_with_validation" do |*args|
          args, tail = ::ValidatiousOnRails::Helpers.extract_args!(*args)
          options = self.attach_validator_for(args.first, args.second, args.extract_options!)
          self.send :"#{field_type}_without_validation", *((args << options) + tail)
        end
        alias_method_chain field_type, :validation
      end

    end

  end
end
