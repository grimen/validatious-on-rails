# encoding: utf-8
require File.join(File.dirname(__FILE__), 'validator')

module ValidatiousOnRails
  module Validatious
    class ServerSideValidator < Validator
      
      def initialize(name, *args)
        super
      end
      
      # TODO: Implement server side validator class, i.e. for validatios that requires AJAX
      
      # Idea:
      #   
      #   Perform AJAX-request to a specified/generated URL
      #   (e.g. /validatious/unique?model=article&attribute=...&value=...), with an attached
      #   callback-method that should trigger a client-side validation.
      #   Well, this is one possible approach...
      #
      
    end
  end
end