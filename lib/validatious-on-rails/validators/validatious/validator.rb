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
# Reference: http://validatious.org/learn/features/core/custom_validators
#
module ValidatiousOnRails
  module Validators
    module Validatious
      class Validator

        attr_accessor :name
        attr_writer   :message,
                      :params,
                      :aliases,
                      :accept_empty,
                      :fn,
                      :args,
                      :data

        def initialize(*args)
          options = args.extract_options!
          self.name ||= self.class.generic_name
          self.message = self.class.generate_message((options.delete(:message) || self.message), self.params)
          self.accept_empty = false
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
        # Default value is: false. Rails default (:allow_nil).
        #
        def accept_empty
          @accept_empty.nil? ? false : @accept_empty
        end

        # TODO: Doc.
        #
        def data
          @data ||= ''
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
            "function(field, value, params){#{value}}"
          end
        end

        def to_js(include_validator = true)
          options = {
              :name => self.name,
              :message => self.message,
              :params => self.params,
              :aliases => self.aliases,
              :acceptEmpty => self.accept_empty,
              :fn => self.fn
            }
          # Just to make the tests much DRYer and maintanable on Ruby 1.8
          # - hash ordered by key only 1.9. ='(
          js_options = options.keys.collect(&:to_s).sort.collect { |k|
              v = options[k.to_sym]
              (("#{k}: #{k.to_sym == :fn ? v : v.to_json}") unless v.blank? && v != false)
            }.compact.join(',')
          js = [self.class.truncate_whitespace(self.data),
                (self.class.truncate_whitespace("v2.Validator.add({#{js_options}});") if include_validator)
          ].compact.join("\n")
        end
        alias :to_s :to_js

        # Generate a full Validatious-style "class function call" to generic validators, e.g.
        # Length::MinimumValidator#to_class(5) => "length-minimum_5", etc.
        #
        def to_class(*args)
          args = @args if args.blank?
          [self.name, (args if args.present?)].flatten.compact.join('_')
        end

        class << self

          def truncate_whitespace(string)
            string.gsub(/[\n]+[\s]+/, '')
          end

          def handle_nil(index = 1)
            %{
              if (v2.present(params[#{index}]) && v2.bool(params[#{index}]) && v2.empty(value)) {
                return true;
              };
            }
          end

          def handle_blank(index = 2)
            %{
              if (v2.present(params[#{index}]) && v2.bool(params[#{index}]) && v2.blank(value)) {
                return true;
              };
              if (v2.present(params[#{index}]) && !v2.bool(params[#{index}])) {
                v2.trimField(field);
                value = v2.trim(value);
              };
            }
          end

          # Generate a unique valdiator ID to avoid clashes.
          # Note: Ruby #hash is way faster than SHA1 (etc.) - just replace any negative sign.
          #
          def generate_id(value)
            value.to_s.hash.to_s.tr('-', '1')
          end

          # Generate proper error message using explicit message, or I18n-lookup.
          # Core validations gets treated by Rails - unless explicit message is set that is.
          #
          def generate_message(key_or_value, options = {})
            message = case true
                      when key_or_value.is_a?(::String)
                        # Explicit message.
                        key_or_value
                      when key_or_value.is_a?(::Symbol)
                        if options.is_a?(::Array)
                          new_options = {}
                          options.each { |v| new_options.merge!(v.to_sym => "{{#{v}}}") }
                          options = new_options
                        end
                        # Lookup message with I18n key.
                        ::I18n.t(key_or_value, options.merge(:scope => :'activerecord.errors.messages',
                          :default => "activerecord.errors.messages.#{key_or_value}"))
                      end
            # Rails I18n interpolations => Validatious interpolations
            # Example: {{count}} => ${count}
            message.to_s.gsub(/\{\{/, '${').gsub(/\}\}/, '}')
          end

          def generic_name
            namespace = self.name.split('::')
            name = []
            name.unshift(namespace.pop) until namespace.blank? || namespace.last == 'Validators'
            name.delete('Validatious') # should not be a case, but had issues with the tests...
            name.join('-').underscore.gsub(/_validator$/, '').gsub(//, '').tr('_', '-')
          end

        end

      end
    end
  end
end
