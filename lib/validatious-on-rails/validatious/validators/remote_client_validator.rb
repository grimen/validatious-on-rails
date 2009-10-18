# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

module ValidatiousOnRails
  module Validatious
    class RemoteClientValidator < ClientSideValidator

      def initialize(validation, options = {})
        super 'remote-client', options
        self.message = self.class.generate_message(validation)
        self.accept_empty = false
        self.fn = %{
          return !!params[0];
        }
      end

    end
  end
end