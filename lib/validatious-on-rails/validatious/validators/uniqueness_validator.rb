# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

module ValidatiousOnRails
  module Validatious
    class UniquenessValidator < RemoteValidator

      def initialize(validation, options = {})
        name = 'uniqueness'
        super name, options
        self.message = self.class.generate_message(validation)
        self.accept_empty = false
        # Identical to Validatious "required" validator, but we want Rails I18n message support, so...
        self.fn = %{
          return true;
        }
        self.fn.freeze
      end

      # TODO: Implement AJAX, etc.
      
      def self.perform_validation(object, attribute_name, value, params = {})
        # TODO: Replace with real implementation.
        if /unique/ =~ value.to_s
          true
        else
          false
        end
      end

    end
  end
end