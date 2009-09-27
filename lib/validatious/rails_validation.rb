# encoding: utf-8
begin
  require 'validation_reflection'
rescue LoadError
  gem 'redinger-validation_reflection', '>= 0.3.2'
  require 'validation_reflection'
end

#
# Force this, as it seems ValidationReflection don't do this correctly. =S
#
ActiveRecord::Base.class_eval do
  include ::ActiveRecordExtensions::ValidationReflection
  ::ActiveRecordExtensions::ValidationReflection.load_config
  ::ActiveRecordExtensions::ValidationReflection.install(self)
end

#
# Validatious-Rails validation translator.
#
module Validatious
  class RailsValidation
    class << self

      # Reference: http://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html

      #
      # Generates form field helper options for a specified object-attribute to
      # reflect on it's validations.
      #
      # Input may be an ActiveRecord class, a class name (string), or an object
      # name along with a method/field.
      #
      def options_for(object_name, attribute_method, options = {})
        validation = self.from_active_record(object_name, attribute_method)

        # Loop validation and add/append pairs to options.
        validation.each_pair do |attribute, value|
          options[attribute] ||= ''
          options[attribute] << value
          # Shake out duplicates.
          options[attribute] = options[attribute].split.uniq.join(' ').strip
        end
        options
      end

      #
      # Groks rails validations, and is able to convert a rails validation to
      # a Validatious 2.0 compatible class string.
      #
      # Input may be an ActiveRecord class, a class name (string), or an object
      # name along with a method/field.
      #
      # Returns a string that will be recognized by Validatious as a class name in
      # form markup.
      #
      def from_active_record(object_or_class, attribute_method)
        klass = object_or_class.to_s.classify.constantize
        options = {:class => ''}
        validation_classes = []

        # Iterate thorugh the validations for the current class,
        # and collect validation options.
        klass.reflect_on_validations_for(attribute_method.to_sym).each do |validation|
          validates_type = validation.macro.to_s.sub(/^validates_/, '')

          # Skip "confirmation_of"-validation info for the attribute that
          # needs to be confirmed. Validatious expects this validation rule
          # on the confirmation field. *
          unless validates_type =~ /^confirmation_of$/
            validation_options = self.send(validates_type, validation)
            validation_classes << validation_options[:class]
          end
        end

        # Special case for "confirmation_of"-validation (see * above).
        if attribute_method.to_s =~ /(.+)_confirmation$/
          confirm_attribute_method = $1
          # Check if validates_confirmation_of(:hello) actually exists,
          # if :hello_confirmation field exists - just to be safe.
          klass.reflect_on_validations_for(confirm_attribute_method.to_sym).each do |validation|
            if validation.macro.to_s =~ /^validates_confirmation_of$/
              validation_options = self.confirmation_of(validation)
              validation_classes << validation_options[:class]
              break
            end
          end
        end

        options[:class] = [options[:class], validation_classes].flatten.compact.join(' ')
        options
      end

      #
      # Resolve validation from validates_acceptance_of.
      #
      # Note: acceptance_of <=> presence_of (for Validatious)
      #
      def acceptance_of(validation)
        {:class => 'required'}
      end

      #
      # Resolve validation from validates_associated.
      #
      # Note: Most probably too hard to implement.
      #
      def associated(validation)
        {:class => ''}
      end

      #
      # Resolve validation from validates_confirmation_of.
      #
      # Note: This validation needed to be treated a bit differently in compare
      #       to the other validations. See "from_active_record".
      #
      def confirmation_of(validation)
        field_id_to_confirm = unless validation.active_record.present?
          "#{validation.active_record.name.tableize.singularize.gsub('/', '_')}_#{validation.name}"
        else
          "#{validation.name}"
        end
        {:class => "confirmation-of_#{field_id_to_confirm}"}
      end

      #
      # TODO: Resolve validation from validates_exclusion_of.
      #
      def exclusion_of(validation)
        {:class => ''}
      end

      #
      # TODO: Resolve validation from validates_format_of.
      #
      # Note: Should be implemented using "Custom validators" - generated and attached to the form on render page.
      #
      def format_of(validation)
        # format_expression = validation.options[:with]
        # Old: {:class => validation.options.key?(:name) ? validation.options[:name] : ''}
        {:class => ''}
      end

      #
      # TODO: Resolve validation from validates_inclusion_of.
      #
      def inclusion_of(validation)
        {:class => ''}
      end

      #
      # Resolve validation from validates_length_of.
      #
      def length_of(validation)
        range = validation.options[:in] || validation.options[:within]
        min, max = nil, nil
        min, max = range.min, range.max if range
        min ||= validation.options[:minimum] || validation.options[:is]
        max ||= validation.options[:maximum] || validation.options[:is]
        
        class_name = [
            ("min-length_#{min}" unless min.nil?),
            ("max-length_#{max}" unless max.nil?)
          ].compact.join(' ')

        {:class => class_name}
      end

      #
      # Resolve validation from validates_numericality_of.
      #
      def numericality_of(validation)
        {:class => 'numeric'}
      end

      #
      # Resolve validation from validates_presence_of.
      #
      # Note: acceptance_of <=> presence_of (for Validatious)
      #
      def presence_of(validation)
        {:class => 'required'}
      end

      #
      # TODO: Resolve validation from validates_uniqueness_of.
      #
      # Note: A bit tricky on the client-side - especially with many records.
      #
      def uniqueness_of(validation)
        {:class => ''}
      end

    end
  end
end