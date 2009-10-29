# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

module ValidatiousOnRails
  module Validatious
    class InclusionInValidator < ClientSideValidator

      def initialize(*args)
        data = args.first.dup
        args.unshift self.class.generate_id(args.shift.inspect)
        super *args
        self.message = self.class.generate_message(:inclusion)
        self.params = %w[include allow_nil allow_blank]
        self.data = %{
          v2.Rails.params['#{args.first}'] = #{data.to_json};
        }
        self.fn = %{
          #{self.class.handle_nil(1)}
          #{self.class.handle_blank(2)}
          var inclusion_values = v2.Rails.params[params[0]];
          for (var i = 0; i < inclusion_values.length; i++) {
            if (inclusion_values[i] == value) { return true; }
          };
          return false;
        }
      end

    end
  end
end