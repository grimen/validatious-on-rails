# encoding: utf-8
require File.join(File.dirname(__FILE__), 'validator')

module ValidatiousOnRails
  module Validators
    module Validatious
      class AjaxValidator < Validator

        #   Override default Validator-fn, with default a AjaxValidator-fn.
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

        class << self

          # Perform the actual validation on the server-side.
          # Requires an instance of the class to validate, the attribute that
          #  needs to be validated, and the current (input) value to validate.
          #
          # Base case: Return "true".
          #
          def validate(record, attribute_name, value, params = {})
            return false if record.blank?
            record.send :"#{attribute_name}=", value

            if record.valid?
              true
            else
              return true if record.errors[attribute_name.to_sym].blank?

              validation_macro = ("validates_%s" % self.generic_name).underscore.gsub(/_remote$/, '')
              validation = record.class.reflect_on_validations_for(attribute_name.to_sym).select { |v|
                  v.macro.to_s == validation_macro
                }.first
              return true if validation.blank?

              puts "ajax_validator: " << self.inspect + " #{validation_macro}"
              validation_error_message = self.translate_interpolation(self.new(validation).message)

              # Ugly, but probably the only way (?) to identify a certain error without open
              # up rails core validation methods - not scalable.
              is_invalid = record.errors[attribute_name.to_sym].any? do |error_message|
                error_message =~ /^#{validation_error_message}$/u
              end

              if is_invalid
                ::ValidatiousOnRails.log "Validation: FAIL: " + record.errors[attribute_name.to_sym].to_s
                false
              else
                true
              end
            end
          end

          # Get the AjaxValidator for a model validation.
          #
          def class_for(validation_name, options = {})
            # Old stuff:
            #   ajax_validators = ::Object.subclasses_of(::ValidatiousOnRails::Validators::Validatious::AjaxValidator)
            #   validator_klass = [*ajax_validators].select { |v| v.to_s == validator_klass_name }.first
            validator_klass_name = "::ValidatiousOnRails::Validators::#{validation_name.to_s.classify}::RemoteValidator"

            # Custom RemoteValidator for current model validation already defined?
            validator_klass = validator_klass_name.constantize rescue nil

            # If AjaxValidator defined (superclass of a RemoteValidator) use it, or define a generic one.
            validator_klass = if validator_klass.is_a?(::ValidatiousOnRails::Validators::Validatious::AjaxValidator)
              validator_klass
            else
              options[:message] ||= validation_name.to_sym
              eval %{
                class #{validator_klass_name} < ::ValidatiousOnRails::Validators::Validatious::AjaxValidator
                  def initialize(*args)
                    self.message = #{options.delete(:message).inspect}
                    super *args
                  end
                end
                #{validator_klass_name}
              }
            end
          end

          # Translate Rails I18n message interpolations to Validatious-compatible
          # message interpolations.
          #
          # Example:
          #   "Only {{count}} apples are allowed." => "Only ${count} apples are allowed."
          #
          def translate_interpolation(message)
            message.gsub(/\{\{.*\}\}/, '.*')
          end

        end

      end
    end
  end
end