# encoding: utf-8
#
# Tap into the built-in form helpers to add validatious class names from
# model validations.
#
module ActionView
  module Helpers
    module FormHelper

      FORM_FIELD_TYPES_A = [:text_field, :password_field, :text_area, :check_box].freeze

      FORM_FIELD_TYPES_A.each do |field_type|
        define_method "#{field_type}_with_validation".to_sym do |*args|
          object_name, method, options = args
          options = ::ValidatiousOnRails::ModelValidations.options_for(object_name, method, options || {})
          self.send "#{field_type}_without_validation", object_name, method, options
        end
        alias_method_chain field_type, :validation
      end

      #
      # Add validation class names to: radio-buttons.
      #
      def radio_button_with_validation(object_name, method, tag_value, options = {})
        options = ::ValidatiousOnRails::ModelValidations.options_for(object_name, method, options)
        radio_button_without_validation(object_name, method, tag_value, options)
      end
      alias_method_chain :radio_button, :validation

      #
      # Adds the title attribute to label tags when there is no title
      # set, and the label text is provided. The title is set to object_name.humanize
      #
      def label_with_title(object_name, method, text = nil, options = {})
        options[:title] ||= method.to_s.humanize unless text.nil?
        label_without_title(object_name, method, text, options)
      end
      alias_method_chain :label, :title

    end
  end
end
