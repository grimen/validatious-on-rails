# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

# TODO: Would be "cool" if each format rule was save as a JS var,
# and referenced with class Validatious style:
#
#   <head>:
#     var ssn-se = /^\d{6}-{4}$/;
#     <<< format validator here >>>
#   <body>:
#     <input type="text" class="format-with_ssn-se" ... />
#
# Same for inclusion/exclusion too. Easy to implement, but low prio.
#
module ValidatiousOnRails
  module Validatious
    class FormatValidator < ClientSideValidator

      def initialize(validation, options = {})
        name, alias_name = self.class.generate_name(validation, :with, self.class.generate_id(validation.options[:with].inspect))
        super name, options
        self.message = self.class.generate_message(validation)
        self.accept_empty = validation.options[:allow_nil]
        self.fn = %{
          #{self.class.validate_blank(validation)}
          return #{validation.options[:with].inspect.gsub(/\\A/,'^').gsub(/\\z/,'$')}.test(value);
        }
        self.fn.freeze
      end

    end
  end
end