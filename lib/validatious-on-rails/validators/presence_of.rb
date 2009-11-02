# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious client_side_validator]))
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious ajax_validator]))

module ValidatiousOnRails
  module Validators
    module PresenceOf

      def self.validators_for(validation)
        Validator.new(:message => :blank)
      end

      class Validator < Validatious::ClientSideValidator
        def initialize(*args)
          self.params = %w[]
          self.fn = %{
            return !v2.empty(value) && !(typeof value.length !== 'undefined' && value.length === 0) && !/^[#{'\s\t\n'}]*$/.test(value);
          }
          super
        end
      end

    end
  end
end