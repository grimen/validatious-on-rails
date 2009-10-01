# encoding: utf-8
require File.join(File.dirname(__FILE__), 'validator')

module ValidatiousOnRails
  module Validatious
    class ServerSideValidator < Validator
      
      def initialize(name, *args)
        super
      end
      
      # TODO: Implement server side validator class, i.e. for validatios that requires AJAX
      
    end
  end
end