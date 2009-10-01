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

      # Reference: http://validatious.org/learn/features/core/custom_validators

      ValidatorError = ::Class.new(::StandardError)

      attr_accessor :name
      attr_writer   :message,
                    :params,
                    :aliases,
                    :accept_empty,
                    :fn

      def initialize(name, *args)
        raise ValidatorError, "Parameter :name is required for an Validatious validator" unless name.present?
        self.name = name
        (options = args.extract_options!).each do |attr, value|
          self.send(:"#{attr}=", value) if value.present?
        end
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

      # This is the method that performs the validation. It receives three arguments,
      # the last one (parameters) may be empty.
      #
      # 1. field is an instance of v2.InputElement, or one of its subclasses. It wraps a
      # label and one or more input/select/textarea elements, and provides convenience
      # such as getValue, getLabel, getName, setName, visible and getParent.
      #
      # 2. value is basically the value of field.getValue(). There is some overhead in
      # fetching the value, and since Validatious already uses it, it passes it along,
      # allowing for an ever so small performance gain.
      #
      # 3. params is an array of parameters registered with the field validator. In the
      # HTML extension, these are the values separated by underscores:
      # class="myval_1" (params[0] === 1).
      #
      # Parameter is required.
      #
      def fn=(value)
        # Handle either full function definition, or just the function body - just because.
        @fn = if (value =~ /function\(\w*,\w*,\w*\).*\{.*\}/i)
          value
        else
          value ||= ''
          # If no function specified yet, always validate true by default.
          value << "\nreturn true;" unless value =~ /return (.+)/i
          "function(field, value, params) {#{value}}"
        end
      end

      def fn
        @fn ||= "function(field, value, params) {return true;}"
      end

      def to_s
        options = {
            :name => self.name,
            :message => self.message,
            :params => self.params,
            :aliases => self.aliases,
            :acceptEmpty => self.accept_empty,
            :fn => self.fn
          }
        js_options = options.collect { |k,v|
            ("#{k}: #{k == :fn ? v : v.to_json}" if [false, true].include?(v) || v.present?)
          }.compact.join(',')
        "v2.Validator.add({#{js_options}});"
      end

    end
  end
end
