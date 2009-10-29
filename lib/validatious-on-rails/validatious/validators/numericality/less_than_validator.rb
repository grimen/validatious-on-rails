# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. validator]))

module ValidatiousOnRails
  module Validatious
    module Numericality
      class LessThanValidator < ClientSideValidator

        def initialize(*args)
          super
          self.message = self.class.generate_message(:less_than, :count => '{{count}}')
          self.params = %w[count allow_nil]
          self.fn = %{
            #{self.class.handle_nil}
            value = +value;
            return value < params[0];
          }
        end

      end
    end
  end
end