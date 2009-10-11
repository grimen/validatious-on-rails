# encoding: utf-8
require File.join(File.dirname(__FILE__), 'validator')

module ValidatiousOnRails
  module Validatious
    class RemoteValidator < Validator
      
      attr_accessor :name
      attr_writer   :message,
                    :accept_empty,
                    :fn,
                    :callbakc_fn,
                    :args
                    
      def initialize(name, *args)
        super
      end

      def message
        @message ||= ''
      end

      def accept_empty
        @accept_empty.nil? ? true : @accept_empty
      end

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

      # TODO: Callback-method on the client-side - handles the AJAX response..
      #
      def callback_fn=
      end

      # TODO: Callback-method on the client-side - handles the AJAX response.
      #
      def callback_fn
        (@callback_fn ||= "function() {return true;}").gsub(/[\n\t]/, '')
      end

      # TODO: Make Validatious trigger the validation on the client-side,
      # which will be a AJAX call to the server-side with enough info to 
      # be able to perform the validation and respond with result that will
      # be handles by the client-side callback function.
      #
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

      # Perform the actual validation on the server-side.
      # Requires an instance of the class to validate, the attribute that
      #  needs to be validated, and the current (input) value to validate.
      #
      def perform_validation(object, attribute_name, value)
        # TODO: Perform server side validation
      end

    end
  end
end