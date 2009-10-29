# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

module ValidatiousOnRails
  module Validatious
    class PresenceValidator < ClientSideValidator

      def initialize(*args)
        super
        self.message = self.class.generate_message(:blank)
        self.params = %w[]
        self.fn = %{
          return !v2.empty(value) && !(typeof value.length !== 'undefined' && value.length === 0) && !/^[#{'\s\t\n'}]*$/.test(value);
        }
      end

    end
  end
end