# encoding: utf-8
begin
  require 'validation_reflection'
rescue LoadError
  gem 'validation_reflection', '>= 0.3.5'
  require 'validation_reflection'
end

require File.join(File.dirname(__FILE__), 'validators')

# Validatious-Rails validation translator.
#
module ValidatiousOnRails
  module ModelValidations

    extend self

    IGNORED_VALIDATIONS = [:each, :associated]

    def validation_methods
      ::ActiveRecord::Base.methods.sort.collect do |m|
        $1.to_s.to_sym if (m.to_s =~ /^validates_(.*)/)
      end.compact - IGNORED_VALIDATIONS
    end

    CORE_VALIDATIONS = self.validation_methods

    # References:
    #   http://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html
    #   http://github.com/rails/rails/blob/13fb26b714dec0874303f51cc125ff62f65a2729/activerecord/lib/active_record/validations.rb

    # Generates form field helper options for a specified object-attribute to
    # reflect on it's validations.
    #
    # Input may be an ActiveRecord class, a class name (string), or an object
    # name along with a method/field.
    #
    def options_for(object_name, attribute_method, options = {}, existing_validators = nil)
      # Handle Nested form.
      object_name = options[:object].present? ? options[:object].class.name : object_name

      validators = self.for_class_method(object_name, attribute_method)
      validator_classes, validator_js = [options[:class]], []

      # Only attach validators that are not already attached.
      validators.flatten.compact.uniq.each do |v|
        # If validator already defined, then only attach meta data.
        validator_is_already_defined = (/name:\s*\"#{v.name}\"/m =~ existing_validators.to_s)
        validator_js << v.to_js(!validator_is_already_defined)
        validator_classes << v.to_class
      end
      js = validator_js.compact.join("\n").strip
      classes = validator_classes.compact.join(' ').strip
      options.merge!(:class => (classes unless classes.blank?), :js => (js unless js.blank?))
    end

    # Groks Rails validations, and is able to convert a rails validation to
    # a Validatious 2.0 compatible class string, and a Validatous validator
    # for more complex validations. Even some of the Rails core validations
    # with certain options requires this.
    #
    # Input may be an ActiveRecord class, a class name (string), or an object
    # name along with a method/field.
    #
    # Returns a string that will be recognized by Validatious as a class name in
    # form markup.
    #
    def for_class_method(object_or_class, attribute_method)
      validators = []
      begin
        klass = if [::String, ::Symbol].any? { |c| object_or_class.is_a?(c) }
          object_or_class.to_s.classify.constantize
        elsif object_or_class.is_a?(::Object)
          object_or_class.class
        else
          object_or_class
        end
        return validators unless klass.respond_to?(:reflect_on_validations_for)
      rescue
        ::ValidatiousOnRails.log "Missing constant: #{object_or_class}", :debug
        return validators
      end

      added_validations = []
      # Iterate thorugh the validations for the current class,
      # and collect validation options.
      klass.reflect_on_validations_for(attribute_method.to_sym).each do |validation|
        validation_id = [validation.macro.to_sym, validation.name.to_sym].hash
        if added_validations.include?(validation_id)
          ::ValidatiousOnRails.log "Duplicate validation detected on #{object_or_class}##{attribute_method}: #{validation.macro}." <<
            " All except the first one will be ignored. Please remove the redundant ones, or try to merge them into just one.", :warn
          next
        end
        added_validations << validation_id

        validates_type = validation.macro.to_s.sub(/^validates?_/, '')

        # Skip "confirmation_of"-validation info for the attribute that
        # needs to be confirmed. Validatious expects this validation rule
        # on the confirmation field. *
        unless validates_type =~ /^confirmation_of$/
          validators << self.for_validation(validates_type, validation)
        end
      end

      # Special case for "confirmation_of"-validation (see * above).
      if attribute_method.to_s =~ /(.+)_confirmation$/
        confirm_attribute_method = $1
        # Check if validates_confirmation_of(:hello) actually exists,
        # if :hello_confirmation field exists - just to be safe.
        klass.reflect_on_validations_for(confirm_attribute_method.to_sym).each do |validation|
          if validation.macro.to_s =~ /^validates_confirmation_of$/
            validators << self.for_validation(:confirmation_of, validation)
            break
          end
        end
      end
      validators.flatten.compact
    end

    def for_validation(validation_name, validation)
      if validation.options[:client_side].nil?
        validation.options[:client_side] = ::ValidatiousOnRails.client_side_validations_by_default?
      end
      begin
        if validation.options[:client_side]
          validation_const = ValidatiousOnRails::Validators.validation_const_for(validation_name)
          validators =  if validation.options[:ajax]
                          validation_const.remote_validator_for(validation)
                        else
                          validation_const.validators_for(validation)
                        end
          if validators.blank?
            ::ValidatiousOnRails.log "No client-side validators defined for #{validation.macro}(#{validation.name}); fallback on AJAX validator."
            validators = validation_const.remote_validator_for(validation) if ::ValidatiousOnRails.fallback_on_ajax_by_default?
          end
          return validators
        end
      rescue NoMethodError => e
        ::ValidatiousOnRails.log "#{validation_const.name}#validators_for not defined - must be implemented. #{e}"
        nil
      end
    end

  end
end
