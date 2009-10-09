# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

# TODO: See notes in FormatValidator.
#
module ValidatiousOnRails
  module Validatious
    class InclusionValidator < ClientSideValidator

      def initialize(validation, options = {})
        name, alias_name = self.class.generate_name(validation, :in, self.class.generate_id(validation.options[:in].inspect))
        super name, options
        self.message = self.class.generate_message(validation)
        self.accept_empty = validation.options[:allow_blank] || validation.options[:allow_nil]
        self.fn = %{
          var inclusion_values = #{validation.options[:in].to_json};
          for (var i = 0; i < inclusion_values.length; i++) {
            if (inclusion_values[i] == value) { return true; }
          };
          return false;
        }
        self.fn.freeze
      end

    end
  end
end