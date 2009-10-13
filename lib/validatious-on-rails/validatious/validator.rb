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

      # The primary name of the validator. This is the name you use with v2.$v('name');
      # and v2.Validator.get('name'); (core API), "field".is("name"); (DSL API) and
      # class="name" (HTML extension).
      #
      # Parameter is required.
      #
      # def name
      #   @name
      # end

      # This is the default error message. It may use named parameters.
      # Parameters can be interpolated into the default message through ${param-name}.
      # All messages have access to ${field}, which resolves to the field name of 
      # he validated field.
      #
      # If the validator takes any parameters, they can also be interpolated into the
      # message, through the name given through the params parameter.
      #
      def message
        @message ||= ''
      end

      # The params parameter provides a mapping between any parameters being sent to
      # the validation method and names to refer to them by when interpolating in the
      # error message.
      #
      # Example: If the fn function uses the value in params[0], you may give this a
      # name by setting params: ['myparam']. In the error message you can then do
      # message: "${field} should obey ${myparam}". When a field fails this message,
      # ${field} will be replaced with the field name, and ${myparam} with the value
      # of the validator function's params[0].
      #
      def params
        @params ||= []
      end

      # An array of additional names for the validator. May make sense especially for
      # the DSL API to be able to refer to a validator by different names.
      #
      def aliases
        @aliases ||= []
      end

      
      # Decides if the validator should pass (return true) when the value is empty.
      # This is usually a good idea because you can leave it up to the required validator
      # to specifically check for emptiness. One benefit of this approach is more 
      # fine grained error reporting, helping the user.
      #
      # Default value is: true.
      #
      def accept_empty
        @accept_empty.nil? ? true : @accept_empty
      end

      # Generate a full Validatious-style "class function call" to generic validators, e.g.
      # Length::MinimumValidator#to_class(5) => "length-minimum_5", etc.
      #
      def to_class(*args)
        args = @args if args.blank?
        [self.name, (args if args.present?)].flatten.compact.join('_')
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
