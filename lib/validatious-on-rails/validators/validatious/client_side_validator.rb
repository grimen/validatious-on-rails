# encoding: utf-8
require File.join(File.dirname(__FILE__), 'validator')

module ValidatiousOnRails
  module Validators
    module Validatious
      class ClientSideValidator < Validator

        # Override default Validator-fn, with default a ClientSideValidator-fn.
        #
        def fn
          self.class.truncate_whitespace(@fn ||= "function(field, value, params){return true;}")
        end

      end
    end
  end
end
