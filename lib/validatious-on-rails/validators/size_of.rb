# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious client_side_validator]))
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious ajax_validator]))

module ValidatiousOnRails
  module Validators
    module SizeOf

      def self.validators_for(validation)
        ::ValidatiousOnRails::Validators::LengthOf.validators_for(validation)
      end

    end
  end
end