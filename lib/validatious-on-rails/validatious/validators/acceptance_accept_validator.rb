# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

module ValidatiousOnRails
  module Validatious
    class AcceptanceAcceptValidator < ClientSideValidator

      def initialize(*args)
        super
        self.message = self.class.generate_message(:accepted)
        self.params = %w[accept allow_nil]
        self.fn = %{
          #{self.class.handle_nil(1)}
          var accept_value = params[0] + '';
          if (accept_value == 'true' || accept_value == 'false') {
            accept_value = v2.bool(accept_value)
          };
          return value == accept_value;
        }
      end

    end
  end
end