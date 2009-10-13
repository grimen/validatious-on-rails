# encoding: utf-8
require File.join(File.dirname(__FILE__), 'validator')

module ValidatiousOnRails
  module Validatious
    class ClientSideValidator < Validator

      # Reference: http://validatious.org/learn/features/core/custom_validators

      ValidatorError = ::Class.new(::StandardError) unless defined?(ValidatorError)

      attr_accessor :name
      attr_writer   :message,
                    :params,
                    :aliases,
                    :accept_empty,
                    :fn,
                    :args

      def initialize(name, *args)
        raise ValidatorError, "Parameter :name is required for an Validatious validator" unless name.present?
        self.name = name
        options = args.extract_options!
        options.each do |attr, value|
          self.send(:"#{attr}=", value) if value.present?
        end
        self.args = args
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
        (@fn ||= "function(field, value, params) {return true;}").gsub(/[\n\t]/, '')
      end

      def to_js
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
            ("#{k}: #{k.to_sym == :fn ? v : v.to_json}" if [false, true].include?(v) || v.present?)
          }.compact.join(', ')
        "v2.Validator.add({#{js_options}});"
      end
      alias :to_s :to_js
      
    end
  end
end