# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

module ValidatiousOnRails
  module Validatious
    class PresenceValidator < ClientSideValidator

      def initialize(validation, options = {})
        name = 'presence'
        super name, options
        self.message = self.class.generate_message(validation, :key => :blank)
        self.accept_empty = false
        # Identical to Validatious "required" validator, but we want Rails I18n message support, so...
        self.fn = %{
          return !v2.empty(value) && !(typeof value.length !== 'undefined' && value.length === 0) && !/^[#{'\s\t\n'}]*$/.test(value);
        }
        self.fn.freeze
      end

    end
  end
end