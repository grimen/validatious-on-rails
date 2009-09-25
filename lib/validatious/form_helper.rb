#
# Tap into the built-in form helpers to add validatious class names from
# model validations.
#
module ActionView
  module Helpers
    module FormHelper

      #
      # Add validation class names to text fields.
      #
      def text_field_with_validation(object_name, method, options = {})
        klass = object_name.to_s.classify.constantize
        options[:class] ||= ''
        validation = ::Validatious::RailsValidation.from_active_record(object_name, method)

        # Loop validation and add/append pairs to options
        validation.each_pair do |attr, value|
          options[attr] ||= ''
          options[attr] << value

          # Shake out duplicates
          options[attr] = options[attr].split.uniq.join(' ')
        end

        text_field_without_validation(object_name, method, options)
      end
      alias_method_chain :text_field, :validation

      #
      # Adds the title attribute to label tags when there is no title
      # set, and the label text is provided. The title is set to object_name.humanize.
      #
      def label_with_title(object_name, method, text = nil, options = {})
        options[:title] ||= method.to_s.humanize unless text.nil?
        label_without_title(object_name, method, text, options)
      end
      alias_method_chain :label, :title

    end
  end
end
