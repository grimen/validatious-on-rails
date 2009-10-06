# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

module ValidatiousOnRails
  module Validatious
    class AcceptanceValidator < ClientSideValidator

      def initialize(validation, options = {})
        name = 'acceptance-accept'
        super name, options
        self.message = self.class.generate_message(validation)
        self.accept_empty = validation.options[:allow_blank] || validation.options[:allow_nil]
        self.fn = %{
          var accept_value = params[0] + '';
          if (accept_value == 'true') {
            accept_value = true
          };
          if (accept_value == 'false') {
            accept_value = false
          };
          return value == accept_value;
        }
        self.fn.freeze
      end

    end
  end
end