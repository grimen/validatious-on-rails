# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. validator]))

module ValidatiousOnRails
  module Validatious
    module Numericality
      class OnlyIntegerValidator < ClientSideValidator

        def initialize(validation, options = {})
          name = 'numericality-only_integer'
          super name, options
          self.message = self.class.generate_message(validation, :key => :not_a_number)
          self.accept_empty = validation.options[:allow_nil]
          self.fn = %{
            value = +value;
            return /\A[+-]?\d+\Z/.test(value);
          }
          self.fn.freeze
        end

      end
    end
  end
end