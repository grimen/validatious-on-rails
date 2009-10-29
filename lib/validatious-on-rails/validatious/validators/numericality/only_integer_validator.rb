# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. validator]))

module ValidatiousOnRails
  module Validatious
    module Numericality
      class OnlyIntegerValidator < ClientSideValidator

        def initialize(*args)
          super
          self.message = self.class.generate_message(:not_a_number, :count => '{{count}}')
          self.params = %w[allow_nil]
          self.fn = %{
            #{self.class.handle_nil(0)}
            value = +value;
            return /^[+-]?\d+$/.test(value);
          }
        end

      end
    end
  end
end