# encoding: utf-8
Dir.glob(File.join(File.dirname(__FILE__), 'validators', '*.rb').to_s).each do |file|
  require file
end

module ValidatiousOnRails
  module Validators

    def self.included(base)
      base.extend Validation
    end

    # Use already defined, or implement a generic module and required interface, for a specified validation.
    # Each validation is following the same namespace pattern, e.g. ::ValidatiousOnRails::Validators::UniquenessOf.
    #
    def self.validation_const_for(validation_name)
      validator_const_name = "::ValidatiousOnRails::Validators::#{validation_name.to_s.classify}"
      begin
        validator_const_name.constantize.send :include, ::ValidatiousOnRails::Validators
        validator_const_name.constantize
      rescue NameError
        eval %{
          module #{validator_const_name}
            include ::ValidatiousOnRails::Validators
          end
        }
        validator_const_name.constantize
      end
    end

    module Validation

      # Generic method that generates an fully implemented remote AJAX validator for any existing
      # model validation based on validation info.
      #
      def default_remote_validator_for(validation, options = {})
        validation.options[:allow_nil] = false if validation.options[:allow_nil].nil?
        validation.options[:allow_blank] = false if validation.options[:allow_blank].nil?
        validation.options[:message] = nil if validation.options[:message].blank?

        validation_name = validation.macro.to_s.gsub(/^validates_/, '')

        # Fallback on auto-generated error message I18n key, if none is specified.
        message = validation.options[:message] || options[:key] || validation_name.gsub(/_of$/, '').to_sym

        Validatious::AjaxValidator.class_for(validation_name.to_sym).new(validation.options[:allow_nil],
          validation.options[:allow_blank], :message => message)
      end
      alias :remote_validator_for :default_remote_validator_for

      # Abstract method that can be overriden to return fully client-side one or many validator(s).
      #
      def default_validators_for(validation, options = {})
        nil
      end
      alias :validators_for :default_validators_for
      alias :validator_for :default_validators_for

    end

  end
end