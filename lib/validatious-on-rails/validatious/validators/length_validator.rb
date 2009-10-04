# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

module ValidatiousOnRails
  module Validatious
    class LengthValidator < ClientSideValidator

      def initialize(validation, options = {})
        name, alias_name = self.class.generate_name(validation, :is, validation.options[:is])
        name = 'length-is'
        super name, options
        self.aliases = [alias_name] - [name]
        self.params = ['count']
        self.message = self.class.generate_message(validation, :key => :wrong_length)
        self.accept_empty = validation.options[:allow_blank] || validation.options[:allow_nil]
        self.fn = %{
          value += '';
          var exact_length = params[0];
          return value == exact_length;
        }
        self.fn.freeze
      end

    end
  end
end