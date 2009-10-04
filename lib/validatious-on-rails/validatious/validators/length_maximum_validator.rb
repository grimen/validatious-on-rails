# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

module ValidatiousOnRails
  module Validatious
    class LengthMaximumValidator < ClientSideValidator

      def initialize(validation, options = {})
        name, alias_name = self.class.generate_name(validation, :maximum, validation.options[:maximum])
        name = 'length-maximum'
        super name, options
        self.aliases = [alias_name] - [name]
        self.params = ['count']
        self.message = self.class.generate_message(validation, :key => :too_long)
        self.accept_empty = validation.options[:allow_blank] || validation.options[:allow_nil]
        self.fn = %{
          value += '';
          var max_length = params[0];
          return value.length <= max_length;
        }
        self.fn.freeze
      end

    end
  end
end