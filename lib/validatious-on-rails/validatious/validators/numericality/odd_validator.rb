# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. validator]))

module ValidatiousOnRails
  module Validatious
    module Numericality
      class OddValidator < ClientSideValidator

        def initialize(*args)
          super
          self.message = self.class.generate_message(:odd)
          self.params = %w[allow_nil]
          self.fn = %{
            #{self.class.handle_nil(0)}
            value = +value;
            return (value % 2) == 1;
          }
        end

      end
    end
  end
end