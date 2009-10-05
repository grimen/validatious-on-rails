# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

# TODO: See notes in FormatValidator.
#
module ValidatiousOnRails
  module Validatious
    class ExclusionValidator < ClientSideValidator

      def initialize(validation, options = {})
        name, alias_name = self.class.generate_name(validation, :in, self.class.generate_id(validation.options[:in].inspect))
        super name, options
        self.aliases = [alias_name] - [name]
        self.message = self.class.generate_message(validation)
        self.accept_empty = validation.options[:allow_blank] || validation.options[:allow_nil]
        self.fn = %{
          var exclusion_values = #{validation.options[:in].to_json};
          for (var i = 0; i < exclusion_values.length; i++) {
            if (exclusion_values[i] == value) { return false; }
          };
          return true;
        }
        self.fn.freeze
      end

    end
  end
end