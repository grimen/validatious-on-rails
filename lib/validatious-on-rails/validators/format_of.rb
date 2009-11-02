# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious client_side_validator]))
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious ajax_validator]))

module ValidatiousOnRails
  module Validators
    module FormatOf

      def self.validators_for(validation)
        validation.options[:allow_nil] = false if validation.options[:allow_nil].nil?
        validation.options[:allow_blank] = false if validation.options[:allow_blank].nil?
        WithValidator.new(validation.options[:with], 
          validation.options[:allow_nil], validation.options[:allow_blank], :message => :invalid)
      end

      class WithValidator < Validatious::ClientSideValidator
        def initialize(*args)
          data = args.first.dup
          args.unshift self.class.generate_id(args.shift.inspect)
          self.params = %w[format allow_nil allow_blank]
          # v2.rails.messages['#{args.first}'] = #{self.message.to_json};
          self.fn = %{
            #{self.class.handle_nil(1)}
            #{self.class.handle_blank(2)}
            return v2.rails.params[params[0]].test(value);
          }
          self.data = %{
            v2.rails.params['#{args.first}'] = #{data.inspect.gsub(/\\A/, '^').gsub(/\\z/, '$')};
          }
          super *args
        end
      end

    end
  end
end