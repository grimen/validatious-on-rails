# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious client_side_validator]))
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious ajax_validator]))

module ValidatiousOnRails
  module Validators
    module UniquenessOf

      def self.remote_validator_for(validation)
        self.default_remote_validator_for(validation, :key => :taken)
      end

   end
  end
end