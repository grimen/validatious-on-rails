#
# Tap into the built-in form helpers to add validatious class names from
# model validations.
#
module ActionView
  module Helpers
    module FormHelper

      #
      # Add validation class names to: text-fields.
      #
      def text_field_with_validation(object_name, method, options = {})
        options = Validatious::RailsValidation.options_for(object_name, method, options)
        text_field_without_validation(object_name, method, options)
      end
      alias_method_chain :text_field, :validation

      #
      # Add validation class names to: password-fields.
      #
      def password_field_with_validation(object_name, method, options = {})
        options = Validatious::RailsValidation.options_for(object_name, method, options)
        password_field_without_validation(object_name, method, options)
      end
      alias_method_chain :password_field, :validation

      #
      # Add validation class names to: text-areas.
      #
      def text_area_with_validation(object_name, method, options = {})
        options = Validatious::RailsValidation.options_for(object_name, method, options)
        text_area_without_validation(object_name, method, options)
      end
      alias_method_chain :text_area, :validation

      #
      # Add validation class names to: check-boxes.
      #
      def check_box_with_validation(object_name, method, options = {}, checked_value = '1', unchecked_value = '0')
        options = Validatious::RailsValidation.options_for(object_name, method, options)
        check_box_without_validation(object_name, method, options)
      end
      alias_method_chain :check_box, :validation

      #
      # Add validation class names to: radio-buttons.
      #
      def radio_button_with_validation(object_name, method, tag_value, options = {})
        options = Validatious::RailsValidation.options_for(object_name, method, options)
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
