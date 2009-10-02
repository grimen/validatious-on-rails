# encoding: utf-8
#
# Tap into the built-in form/input helpers to add validatious class names from
# model validations.
#
module ActionView # :nodoc:
  module Helpers # :nodoc:
    module FormHelper # :nodoc:

      FIELD_TYPES = [:text_field, :password_field, :text_area, :file_field, :radio_button].freeze

      # Only altering the options hash is interesting - we want to set a validator class for fields,
      # so the hooking of these helpers don't have to be very explicit.
      #      
      FIELD_TYPES.each do |field_type|
        define_method "#{field_type}_with_validation".to_sym do |*args|
          options = args.extract_options!
          # Get the validation options.
          options = ::ValidatiousOnRails::ModelValidations.options_for(args.first, args.second, options)

          # Attach custom validator - if any - to the layout (in the <head>-tag - the unobtrusive way).
          validators = options.delete(:validators)
          content_for :validatious, validators if validators.present?

          self.send "#{field_type}_without_validation".to_sym, *(args << options)
        end
        alias_method_chain field_type, :validation
      end

      # Special case...no hash as last argument.
      #
      def check_box_with_validation(object_name, method, options = {}, checked_value = '1', unchecked_value = '0')
        # Get the validation options.
        options = ::ValidatiousOnRails::ModelValidations.options_for(object_name, method, options)
        # Attach custom validator - if any - to the layout (in the <head>-tag - the unobtrusive way).
        validators = options.delete(:validators)
        content_for :validatious, validators if validators.present?
        self.check_box_without_validation object_name, method, options, checked_value, unchecked_value
      end
      alias_method_chain :check_box, :validation

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

      FIELD_TYPES = [:time_zone_select, :select, :collection_select, :grouped_options_for_select]

      FIELD_TYPES.each do |field_type|
        define_method "#{field_type}_with_validation".to_sym do |*args|
          options = args.extract_options!
          # Get the validation options.
          options = ::ValidatiousOnRails::ModelValidations.options_for(args.first, args.second, options)

          # Attach custom validator - if any - to the layout (in the <head>-tag - the unobtrusive way).
          validators = options.delete(:validators)
          content_for :validatious, validators if validators.present?

          self.send "#{field_type}_without_validation".to_sym, *(args << options)
        end
        alias_method_chain field_type, :validation
      end

    end

    module DateHelper

      FIELD_TYPES = [:date_select, :datetime_select, :time_select]

      FIELD_TYPES.each do |field_type|
        define_method "#{field_type}_with_validation".to_sym do |*args|
          options = args.extract_options!
          # Get the validation options.
          options = ::ValidatiousOnRails::ModelValidations.options_for(args.first, args.second, options)

          # Attach custom validator - if any - to the layout (in the <head>-tag - the unobtrusive way).
          validators = options.delete(:validators)
          content_for :validatious, validators if validators.present?

          self.send "#{field_type}_without_validation".to_sym, *(args << options)
        end
        alias_method_chain field_type, :validation
      end

    end

  end
end
