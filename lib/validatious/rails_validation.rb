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
      def options_for(object_name, method, options = {})
        validation = self.from_active_record(object_name, method)

        # Loop validation and add/append pairs to options.
        validation.each_pair do |attr, value|
          options[attr] ||= ''
          options[attr] << value

          # Shake out duplicates.
          options[attr] = options[attr].split.uniq.join(' ').strip
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
      def from_active_record(object_or_class, method)
        klass = object_or_class.to_s.classify.constantize
        options = {:class => ''}
        validation_classes = []
        
        # Iterate thorugh the validations for the current class,
        # and collect validation options.
        klass.reflect_on_validations_for(method).each do |validation|
          validation_options = self.send(validation.macro.to_s.sub(/^validates_/, ''), validation)
          validation_classes << validation_options[:class]
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
      def associated(validation)
        {:class => ''}
      end

      #
      # TODO: Resolve validation from validates_confirmation_of.
      #
      # Note: Should be added to "#{field}_confirmation" instead of "#{field}", i.e. non-standard approach.
      #
      def confirmation_of(validation)
        {:class => ''}
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