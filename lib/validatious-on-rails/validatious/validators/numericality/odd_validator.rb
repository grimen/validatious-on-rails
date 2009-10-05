# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. validator]))

module ValidatiousOnRails
  module Validatious
    module Numericality
      class OddValidator < ClientSideValidator

        def initialize(validation, options = {})
          name = 'numericality-odd'
          super name, options
          self.message = self.class.generate_message(validation, :key => :odd)
          self.accept_empty = validation.options[:allow_nil]
          self.fn = %{
            value = +value;
            return (value % 2) == 1;
          }
          self.fn.freeze
        end

      end
    end
  end
end