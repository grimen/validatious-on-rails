# encoding: utf-8
require File.join(File.dirname(__FILE__), 'validator')

module ValidatiousOnRails
  module Validatious
    class ClientSideValidator < Validator
      
      def initialize(name, *args)
        super
      end
      
    end
  end
end