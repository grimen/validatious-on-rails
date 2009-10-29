# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. validator]))

module ValidatiousOnRails
  module Validatious
    module Length
      class IsValidator < ClientSideValidator

        def initialize(*args)
          super
          self.message = self.class.generate_message(:wrong_length, :count => '{{count}}')
          self.params = %w[count allow_nil allow_blank]
          self.fn = %{
            value += '';
            #{self.class.handle_nil}
            #{self.class.handle_blank}
            return value.length == params[0];
          }
        end

      end
    end
  end
end