# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious client_side_validator]))
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious ajax_validator]))

module ValidatiousOnRails
  module Validators
    module InclusionOf

      def self.validators_for(validation)
        validation.options[:allow_nil] = false if validation.options[:allow_nil].nil?
        validation.options[:allow_blank] = false if validation.options[:allow_blank].nil?
        InValidator.new(validation.options[:in],
          validation.options[:allow_nil], validation.options[:allow_blank], :message => :inclusion)
      end

      class InValidator < Validatious::ClientSideValidator
        def initialize(*args)
          data = args.first.dup
          args.unshift self.class.generate_id(args.shift.inspect)
          self.params = %w[include allow_nil allow_blank]
          self.fn = %{
            #{self.class.handle_nil(1)}
            #{self.class.handle_blank(2)}
            var inclusion_values = v2.rails.params[params[0]];
            for (var i = 0; i < inclusion_values.length; i++) {
              if (inclusion_values[i] == value) { return true; }
            };
            return false;
          }
          self.data = %{
            v2.rails.params['#{args.first}'] = #{data.to_json};
          }
          super *args
        end
      end

    end
  end
end