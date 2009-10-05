# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. validator]))

module ValidatiousOnRails
  module Validatious
    module Length
      class IsValidator < ClientSideValidator

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
            return value == params[0];
          }
          self.fn.freeze
        end

      end
    end
  end
end