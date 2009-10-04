# encoding: utf-8
begin
  require 'validation_reflection'
rescue LoadError
  gem 'redinger-validation_reflection', '>= 0.3.2'
  require 'validation_reflection'
end

require File.join(File.dirname(__FILE__), *%w[validatious validators])

# Force this, as it seems ValidationReflection don't do this correctly. =S
#
ActiveRecord::Base.class_eval do
  include ::ActiveRecordExtensions::ValidationReflection
  ::ActiveRecordExtensions::ValidationReflection.load_config
  ::ActiveRecordExtensions::ValidationReflection.install(self)
end

# Validatious-Rails validation translator.
#
module ValidatiousOnRails
  class ModelValidations

    CORE_VALIDATIONS = [
        :acceptance_of,
        :associated,
        :confirmation_of,
        :exclusion_of,
        :format_of,
        :inclusion_of,
        :length_of,
        :numericality_of,
        :presence_of,
        :uniqueness_of
      ].freeze
    SUPPORTED_VALIDATIONS = CORE_VALIDATIONS

    class << self

      # References:
      #   http://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html
      #   http://github.com/rails/rails/blob/13fb26b714dec0874303f51cc125ff62f65a2729/activerecord/lib/active_record/validations.rb

      # Generates form field helper options for a specified object-attribute to
      # reflect on it's validations.
      #
      # Input may be an ActiveRecord class, a class name (string), or an object
      # name along with a method/field.
      #
      def options_for(object_name, attribute_method, options = {})
        validation = self.from_active_record(object_name, attribute_method)
        options.merge!(
            :class => [options[:class], validation[:classes]].flatten.compact.uniq.join(' '),
            :validators => validation[:validators].flatten.compact.uniq
          )
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
      def from_active_record(object_or_class, attribute_method)
        klass = object_or_class.to_s.classify.constantize
        attribute_validation = {:classes => [], :validators => []}

        # Iterate thorugh the validations for the current class,
        # and collect validation options.
        klass.reflect_on_validations_for(attribute_method.to_sym).each do |validation|
          validates_type = validation.macro.to_s.sub(/^validates?_/, '')

          # Skip "confirmation_of"-validation info for the attribute that
          # needs to be confirmed. Validatious expects this validation rule
          # on the confirmation field. *
          unless validates_type =~ /^confirmation_of$/
            validation_options = self.send(validates_type.to_sym, validation)
            attribute_validation[:classes] << validation_options[:class]
            # One or multiple validators for each validation (possible to combine validators).
            attribute_validation[:validators] << validation_options[:validator] || validation_options[:validators]
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
              attribute_validation[:classes] << validation_options[:class]
              break
            end
          end
        end
        attribute_validation
      end

      # Resolve validation from validates_acceptance_of.
      #
      # Alias, but might change: acceptance_of <=> presence_of
      #
      # TODO: Make this a custom validator - handle :accept.
      #
      # NOTE: Not supported:
      #   * :accept - TODO: not taken into consideration
      #                 right now (but must have value "true" for db column values)
      #   * :allow_nil - TODO.
      #   * :on - TODO.
      #   * :if/:unless - hard to port all to client-side JavaScript
      #                   (impossible: procs, unaccessible valiables, etc.).
      #
      def acceptance_of(validation)
        {:class => 'required', :validator => nil}
      end

      # Resolve validation from validates_associated.
      #
      # NOTE: Not supported - low prio.
      #
      def associated(validation)
        {:class => '', :validator => nil}
      end

      # Resolve validation from validates_confirmation_of.
      # This validation is treated a bit differently in compare
      # to the other validations. See "from_active_record".
      #
      # NOTE: Not supported:
      #   * :on - TODO.
      #   * :if/:unless - hard to port all to client-side JavaScript
      #                   (impossible: procs, unaccessible valiables, etc.).
      #
      def confirmation_of(validation)
        field_id_to_confirm = unless validation.active_record.present?
          "#{validation.active_record.name.tableize.singularize.gsub('/', '_')}_#{validation.name}"
        else
          "#{validation.name}"
        end
        {:class => "confirmation-of_#{field_id_to_confirm}", :validator => nil}
      end

      # Resolve validation from validates_exclusion_of.
      #
      # Attaching custom validator - with a unique name based on the exclusion values.
      #
      # NOTE: Not supported:
      #   * :on - TODO.
      #   * :if/:unless - hard to port all to client-side JavaScript
      #                   (impossible: procs, unaccessible valiables, etc.).
      #
      def exclusion_of(validation)
        validator = Validatious::ExclusionValidator.new(validation)
        {:class => validator.name, :validator => validator}
      end

      # Resolve validation from validates_format_of.
      #
      # Attaching custom validator, with a unique name based on the regular expression.
      # Needs regexp.inspect to get it right.
      #
      # NOTE: Not supported:
      #   * :on - TODO.
      #   * :if/:unless - hard to port all to client-side JavaScript
      #                   (impossible: procs, unaccessible valiables, etc.).
      #
      def format_of(validation)
        validator = Validatious::FormatValidator.new(validation)
        {:class => validator.name, :validator => validator}
      end

      # Resolve validation from validates_inclusion_of.
      #
      # Attaching custom validator - with a unique name based on the inclusion values.
      #
      # NOTE: Not supported:
      #   * :on - TODO.
      #   * :if/:unless - hard to port all to client-side JavaScript
      #                   (impossible: procs, unaccessible valiables, etc.).
      #
      def inclusion_of(validation)
        validator = Validatious::InclusionValidator.new(validation)
        {:class => validator.name, :validator => validator}
      end

      # Resolve validation from validates_length_of.
      #
      # Example (of generated field classes):
      #   length-is-5, length-maximum-2, length-minimum-2, length-within-2-10, etc.
      #
      # NOTE: Not supported:
      #   * :tokenizer - see: :if/:unless
      #   * :on - TODO.
      #   * :if/:unless - hard to port all to client-side JavaScript
      #                   (impossible: procs, unaccessible valiables, etc.).
      #
      def length_of(validation)
        validator, min, max = case true
        when validation.options[:is].present?
          [Validatious::LengthValidator.new(validation), validation.options[:is], validation.options[:is]]
        when [:in, :within].any? { |k| validation.options[k].present? } ||
              [:minimum, :maximum].all? { |k| validation.options[k].present? }
          validation.options[:within] ||=
            validation.options[:in] ||
            (validation.options[:minimum].to_i..validation.options[:maximum].to_i)
          [[Validatious::LengthMinimumValidator.new(validation), Validatious::LengthMaximumValidator.new(validation)],
            validation.options[:within].min, validation.options[:within].max]
        when validation.options[:minimum].present?
          [Validatious::LengthMinimumValidator.new(validation), validation.options[:minimum], nil]
        when validation.options[:maximum].present?
          [Validatious::LengthMaximumValidator.new(validation), nil, validation.options[:maximum]]
        end
        validator = [*validator]
        # This piece of code is a bit diffuse, but works. =)
        classes = [
            ("#{validator.first.name}_#{min}" if min),
            ("#{validator.last.name}_#{max}" if max)
          ].compact.uniq.join(' ')
        {:class => classes, :validator => validator}
      end
      alias :size_of :length_of

      # Resolve validation from validates_numericality_of.
      #
      # NOTE: Not supported:
      #   * :only_integer - TODO.
      #   * :allow_nil - TODO.
      #   * :greater_than - TODO.
      #   * :greater_than_or_equal_to - TODO.
      #   * :equal_to - TODO.
      #   * :less_than - TODO.
      #   * :less_than_or_equal_to - TODO.
      #   * :odd - TODO.
      #   * :even - TODO.
      #
      #   For custom validator, use Rails numericality_of-regex: /A[+-]?d+Z/
      #
      def numericality_of(validation)
        {:class => 'numeric', :validator => nil}
      end

      # Resolve validation from validates_presence_of.
      #
      # Alias, but might change: acceptance_of <=> presence_of
      #
      # NOTE: Not supported:
      #   * :on - TODO.
      #   * :if/:unless - hard to port all to client-side JavaScript
      #                   (impossible: procs, unaccessible valiables, etc.).
      #
      def presence_of(validation)
        {:class => 'required', :validator => nil}
      end

      # Resolve validation from validates_uniqueness_of.
      #
      # TODO: Implement using RemoteValidator.
      #
      def uniqueness_of(validation)
        {:class => '', :validator => nil}
      end

      # Unknown validations - if no matching custom validator is found/registered.
      #
      def method_missing(sym, *args, &block)
        ::ValidatiousOnRails.log "Unknown validation: #{sym}." <<
          " No custom Validatious validator found for this validation makro. " <<
          "Maybe you forgot to register you custom validation using: " <<
          "ValidatiousOnRails::ModelValidations.add(<CustomValidationClass>)", :warn
        {:class => '', :validator => nil}
      end

      # TODO: Include custom validations here...
      #
      # @custom_validators.each { |validator_class| ... }

    end
  end
end
