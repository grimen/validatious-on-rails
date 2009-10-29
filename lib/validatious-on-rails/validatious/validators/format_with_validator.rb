# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

module ValidatiousOnRails
  module Validatious
    class FormatWithValidator < ClientSideValidator

      def initialize(*args)
        data = args.first.dup
        args.unshift self.class.generate_id(args.shift.inspect)
        super *args
        self.message = self.class.generate_message(:invalid)
        self.params = %w[format allow_nil allow_blank]
        self.data = %{
          v2.Rails.params['#{args.first}'] = #{data.inspect.gsub(/\\A/, '^').gsub(/\\z/, '$')};
        }
        # v2.Rails.messages['#{args.first}'] = #{self.message.to_json};
        self.fn = %{
          #{self.class.handle_nil(1)}
          #{self.class.handle_blank(2)}
          return v2.Rails.params[params[0]].test(value);
        }
      end

    end
  end
end