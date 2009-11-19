# encoding: utf-8
require File.join(File.dirname(__FILE__), 'validator')

module ValidatiousOnRails
  module Validatious
    class RemoteValidator < Validator

      def initialize(*args)
        super
      end

      # Override default Validator-fn, with default a RemoteValidator-fn.
      #
      #   1. Perform AJAX request (dependencies: validatious-on-rails.js, XMLHttpRequest.js).
      #   2. Always return last result, callback-function should perform the actual client side validation.
      #
      def fn
        self.class.truncate_whitespace(@fn ||= %{
            function(field, value, params) {
              value += '';
              #{self.class.handle_nil(0)}
              #{self.class.handle_blank(1)}
              return v2.rails.performRemoteValidation(#{self.name.to_json}, field, value, params, #{self.message.to_json});
            }
          })
      end

      def to_js
         if ::ValidatiousOnRails.remote_validations_enabled
           super
         else
           "// remote validations disabled"
         end
      end

      class << self

        # Perform the actual validation on the server-side.
        # Requires an instance of the class to validate, the attribute that
        #  needs to be validated, and the current (input) value to validate.
        #
        # Base case: Return "true".
        #
        def perform_validation(record, attribute_name, value, params = {})
          return true if record.blank?
          record.send :"#{attribute_name}=", value

          if record.valid?
            ValidatiousOnRails.log "Validation: SUCCESS"
            true
          else
            return true if record.errors[attribute_name.to_sym].blank?

            # TODO: Refactor this when "the better" namin convention is used (see TODO).
            validation_macro = ("validates_%s" % self.generic_name)
            validation = record.class.reflect_on_validations_for(attribute_name.to_sym).select { |v|
                v.macro.to_s == validation_macro || v.macro.to_s == "#{validation_macro}_of"
              }.first
            return true if validation.blank?

            # {{variable}} => .*
            validation_error_message = self.new(validation).message.gsub(/\{\{.*\}\}/, '.*')

            # Ugly, but probably the only way (?) to identify a certain error without open
            # up rails core validation methods - not scalable.
            is_invalid = record.errors[attribute_name.to_sym].any? do |error_message|
              #ValidatiousOnRails.log error_message + " =~ " + /^#{validation_error_message}$/.inspect
              error_message =~ /^#{validation_error_message}$/u
            end

            if is_invalid
              ValidatiousOnRails.log "Validation: FAIL: " + record.errors[attribute_name.to_sym].to_s
              false
            else
              true
            end
          end
        end

      end

    end
  end
end