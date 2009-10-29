# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

# TODO/QUESTION: Should message be thrown on the confirmation field or the confirmed field (Rails).
# First makes most sense, but not the Rails way.
#
module ValidatiousOnRails
  module Validatious
    class ConfirmationOfValidator < ClientSideValidator

      def initialize(*args)
        super
        self.message = self.class.generate_message(:confirmation)
        self.params = %w[field-id]
        self.fn = %{
          return value === v2.$f(params[0]).getValue();
        }
      end

    end
  end
end