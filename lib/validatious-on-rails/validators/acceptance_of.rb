# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious client_side_validator]))
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious ajax_validator]))

module ValidatiousOnRails
  module Validators
    module AcceptanceOf

      def self.validators_for(validation)
        validation.options[:allow_nil] = false if validation.options[:allow_nil].nil?
        validation.options[:accept] ||= '1' # Rails default.
        AcceptValidator.new(validation.options[:accept], validation.options[:allow_nil], :message => :accepted)
      end

      class AcceptValidator < Validatious::ClientSideValidator
        def initialize(*args)
          self.params = %w[accept allow_nil]
          self.fn = %{
            #{self.class.handle_nil(1)}
            var accept_value = params[0] + '';
            if (accept_value == 'true' || accept_value == 'false') {
              accept_value = v2.bool(accept_value)
            };
            return value == accept_value;
          }
          super
        end
      end

    end
  end
end