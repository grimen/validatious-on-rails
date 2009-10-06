# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

module ValidatiousOnRails
  module Validatious
    class ConfirmationValidator < ClientSideValidator

      def initialize(validation, options = {})
        name = 'confirmation-of'
        super name, options
        self.message = self.class.generate_message(validation)
        self.accept_empty = validation.options[:allow_nil]
        self.fn = %{
          // var confirmation_value = document.getElementById(params[0]);
          // TODO...
          return false;
        }
        self.fn.freeze
      end

    end
  end
end