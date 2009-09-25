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
        options = { :class => '' }

        klass.reflect_on_validations_for(method).each do |validation|
          opts = send(validation.macro.to_s.sub(/^validates_/, ''), validation)
          options[:class] << " #{opts[:class]}"
        end

        options
      end

      #
      # Resolve validation from validates_acceptance_of.
      #
      def acceptance_of(validation)
        { :class => '' }
      end

      #
      # Resolve validation from validates_associated.
      #
      def associated(validation)
        { :class => '' }
      end

      #
      # Resolve validation from validates_confirmation_of.
      #
      def confirmation_of(validation)
        { :class => '' }
      end

      #
      # Resolve validation from validates_exclusion_of.
      #
      def exclusion_of(validation)
        { :class => '' }
      end

      #
      # Resolve validation from validates_format_of.
      #
      def format_of(validation)
        { :class => validation.options.key?(:name) ? validation.options[:name] : "" }
      end

      #
      # Resolve validation from validates_inclusion_of.
      #
      def inclusion_of(validation)
        { :class => "" }
      end

      #
      # Resolve validation from validates_length_of.
      #
      def length_of(validation)
        range = validation.options[:in] || validation.options[:within]
        min, max = nil, nil
        min, max = range.min, range.max if range
        min ||= validation.options[:minimum]
        max ||= validation.options[:maximum]
        class_name = [
            ("min-length_#{min}" unless min.nil?),
            ("max-length_#{max}" unless max.nil?)
          ].compact.join(' ')

        { :class => class_name }
      end

      #
      # Resolve validation from validates_numericality_of.
      #
      def numericality_of(validation)
        { :class => 'numeric' }
      end

      #
      # Resolve validation from validates_presence_of.
      #
      def presence_of(validation)
        { :class => 'required' }
      end

      #
      # Resolve validation from validates_uniqueness_of.
      #
      def uniqueness_of(validation)
        { :class => '' }
      end

    end
  end
end