# encoding: utf-8

# Ruby-representation of a custom Validatious validator ("v2.Validator").
#
# Example (JavaScript representation):
#
#   v2.Validator.add(
#     name: 'validator-name',
#     message: 'Default error message',
#     params: ['a', 'list', 'of', 'named', 'parameters'],
#     aliases: ['list', 'of', 'alternative', 'names'],
#     acceptEmpty: true,
#     fn: function(field, value, params) {
#       // Should return true if field/value is valid
#     }
#   });
# 
module ValidatiousOnRails
  module Validatious
    class Validator

      def initialize(name, *args)
        raise ValidatorError, "Parameter :name is required for an Validatious validator" unless name.present?
        self.name = name
        options = args.extract_options!
        options.each do |attr, value|
          self.send(:"#{attr}=", value) if value.present?
        end
        self.args = args
      end

      class << self

        def validate_blank(validation)
          %{
            var isBlank = /^[\s\t\n]*$/.test(value);
            if (#{validation.options[:allow_blank] == true} && isBlank) {
              return true;
            };
          }
        end

        # Generate a unique valdiator ID to avoid clashes.
        # Note: Ruby #hash is way faster than SHA1 (etc.) - just replace any negative sign.
        #
        def generate_id(value)
          value.to_s.hash.to_s.tr('-', '1')
        end

        # Any named specified for this custom validation?
        # E.g. validates_format_of :name, :with => /\d{6}-\d{4}/, :name => 'ssn-se'
        #
        # If not, create one that's uniqe based on validation and what to validate based on,
        # e.g. validates_format_of :name, :with => /\d{6}-\d{4}/ # => :name => "format_with_#{hash-of-:with-value}"
        #
        def generate_name(validation, id_key, id_value = nil)
          # Avoiding duplicates...
          identifier = "-#{id_value}" if id_value.present?
          validator_id = "#{validation.macro.to_s.sub(/^validates_/, '').sub(/_of/, '')}_#{id_key}#{identifier}"
          name = validation.options[:name].present? ? validation.options[:name] : validator_id
          # "_" is not allowed in name/alias(es) - used to seperate validator-id from it's args/params.
          [name, validator_id].collect! { |v| v.tr('_', '-') }
        end

        # Generate proper error message using explicit message, or I18n-lookup.
        # Core validations gets treated by Rails - unless explicit message is set that is.
        #
        # NOTE: Might refactor this into a even more abstract class/module.
        #
        def generate_message(validation, *args)
          options = args.extract_options!
          explicit_message = validation.options[:message]
          key = options.delete(:key) || (explicit_message if explicit_message.is_a?(::Symbol))

          message = if key.present?
            ::I18n.t(key, options.merge(:scope => :'activerecord.errors.messages',
              :default => "activerecord.errors.messages.#{key}"))
          elsif explicit_message.is_a?(::String)
            explicit_message
          else
            unless ::ValidatiousOnRails::ModelValidations::CORE_VALIDATIONS.include?(validation.macro.to_sym)
              # No core validation, try to make up a descent I18n lookup path using conventions.
              key ||= validation.macro.to_s.tr('-', '_').gsub(/^validates?_/, '').gsub(/_of/, '').to_sym
              ::I18n.t(key, options.merge(:scope => :'activerecord.errors.messages',
                :default => "activerecord.errors.messages.#{key}"))
            else
              # Nothing - let Rails rails handle the core validation message translations (I18n).
            end
          end
          # Rails I18n interpolations => Validatious interpolations
          # Example: {{count}} => ${count}
          message.gsub(/\{\{/, '${').gsub(/\}\}/, '}')
        end

      end

    end
  end
end
