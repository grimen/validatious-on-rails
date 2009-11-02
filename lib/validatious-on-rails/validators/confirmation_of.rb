# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious client_side_validator]))
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious ajax_validator]))

module ValidatiousOnRails
  module Validators
    module ConfirmationOf

      def self.validators_for(validation)
        field_id = unless validation.active_record.present?
          "#{validation.active_record.name.tableize.singularize.tr('/', '_')}_#{validation.name}"
        else
          "#{validation.name}"
        end
        Validator.new(field_id, :message => :confirmation)
      end

      class Validator < Validatious::ClientSideValidator
        def initialize(*args)
          self.params = %w[field-id]
          self.fn = %{
            return value === v2.$f(params[0]).getValue();
          }
          super *args
        end
      end

    end
  end
end