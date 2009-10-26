# encoding: utf-8
begin
  require 'validation_reflection'
rescue LoadError
  gem 'validation_reflection', '>= 0.3.5'
  require 'validation_reflection'
end

require File.join(File.dirname(__FILE__), *%w[validatious validators])

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
      def options_for(object_name, attribute_method, options = {}, existing_validators = nil)
        # Handle Nested form.
        object_name = options[:object].present? ? options[:object].class.name : object_name
        
        validators = self.from_active_record(object_name, attribute_method)
        validator_classes, validator_js = [options[:class]], []

        # Only attach validators that are not already attached.
        validators.flatten.compact.uniq.each do |v|
          validator_js << v.to_js unless existing_validators.present? && /#{v.name}/ =~ existing_validators
          validator_classes << v.to_class
        end
        classes = validator_classes.compact.join(' ').strip
        js = validator_js.compact.join("\n").strip
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
      def from_active_record(object_or_class, attribute_method)
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

        # Iterate thorugh the validations for the current class,
        # and collect validation options.
        klass.reflect_on_validations_for(attribute_method.to_sym).each do |validation|
          validates_type = validation.macro.to_s.sub(/^validates?_/, '')
          if validation.options[:client_side].nil?
            validation.options[:client_side] = ::ValidatiousOnRails.client_side_validations_by_default
          end

          # Skip "confirmation_of"-validation info for the attribute that
          # needs to be confirmed. Validatious expects this validation rule
          # on the confirmation field. *
          unless validates_type =~ /^confirmation_of$/
            validators << self.send(validates_type.to_sym, validation) if validation.options[:client_side]
          end
        end

        # Special case for "confirmation_of"-validation (see * above).
        if attribute_method.to_s =~ /(.+)_confirmation$/
          confirm_attribute_method = $1
          # Check if validates_confirmation_of(:hello) actually exists,
          # if :hello_confirmation field exists - just to be safe.
          klass.reflect_on_validations_for(confirm_attribute_method.to_sym).each do |validation|
            if validation.options[:client_side].nil?
              validation.options[:client_side] = ::ValidatiousOnRails.client_side_validations_by_default
            end

            if validation.macro.to_s =~ /^validates_confirmation_of$/
              validators << self.confirmation_of(validation) if validation.options[:client_side]
              break
            end
          end
        end
        validators.flatten.compact
      end

      # Resolve validation from validates_acceptance_of.
      #
      # Alias, but might change: acceptance_of <=> presence_of
      #
      # NOTE: Not supported:
      #   * :on - TODO.
      #   * :if/:unless - hard to port all to client-side JavaScript
      #                   (impossible: procs, unaccessible valiables, etc.).
      #
      def acceptance_of(validation)
        validators = []
        validation.options[:accept] ||= '1' # Rails default.
        validators << Validatious::AcceptanceValidator.new(validation, validation.options[:accept])
      end

      # Resolve validation from validates_associated.
      #
      # NOTE: Not supported - low prio.
      #
      def associated(validation)
        nil
      end

      # Resolve validation from validates_confirmation_of.
      # This validation is treated a bit differently in compare
      # to the other validations. See "from_active_record".
      #
      # TODO: Message should be Rails I18n message, not Validatious.
      #
      # NOTE: Not supported:
      #   * :message - TODO: Explicit or Rails I18n/default message.
      #   * :on - TODO.
      #   * :if/:unless - hard to port all to client-side JavaScript
      #                   (impossible: procs, unaccessible valiables, etc.).
      #
      def confirmation_of(validation)
        validators = []
        arg = unless validation.active_record.present?
          "#{validation.active_record.name.tableize.singularize.gsub('/', '_')}_#{validation.name}"
        else
          "#{validation.name}"
        end
        validators << Validatious::ConfirmationValidator.new(validation, arg)
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
        validators = []
        validators << Validatious::ExclusionValidator.new(validation)
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
        validators = []
        validators << Validatious::FormatValidator.new(validation)
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
        validators = []
        validators << Validatious::InclusionValidator.new(validation)
      end

      # Resolve validation from validates_length_of.
      #
      # Example (of generated field classes):
      #   length-is_5, length-maximum_2, length-minimum_2, etc.
      #
      # NOTE: Not supported:
      #   * :tokenizer - see: :if/:unless
      #   * :on - TODO.
      #   * :if/:unless - hard to port all to client-side JavaScript
      #                   (impossible: procs, unaccessible valiables, etc.).
      #
      def length_of(validation)
        validators = []

        if validation.options[:is].present?
          validators << Validatious::Length::IsValidator.new(validation, validation.options[:is])
        elsif [:in, :within, :minimum, :maximum].any? { |k| validation.options[k].present? }
          validation.options[:within] ||= validation.options[:in]
          validation.options[:minimum] ||= validation.options[:within].min rescue nil
          validation.options[:maximum] ||= validation.options[:within].max rescue nil

          if validation.options[:minimum].present?
            validators << Validatious::Length::MinimumValidator.new(validation, validation.options[:minimum])
          end

          if validation.options[:maximum].present?
            validators << Validatious::Length::MaximumValidator.new(validation, validation.options[:maximum])
          end
        end

        validators
      end
      alias :size_of :length_of

      # Resolve validation from validates_numericality_of.
      #
      # Example (of generated field classes):
      #   numericality-odd, numericality-only-integer, numericality-equal-to_5, etc.
      #
      # NOTE: Not supported:
      #   * :on - TODO.en
      #   * :if/:unless - hard to port all to client-side JavaScript
      #                   (impossible: procs, unaccessible valiables, etc.).
      #
      def numericality_of(validation)
        validators = []

        if validation.options[:odd] && !validation.options[:even]
          validators << Validatious::Numericality::OddValidator.new(validation)
        end

        if validation.options[:even] && !validation.options[:odd]
          validators << Validatious::Numericality::EvenValidator.new(validation)
        end

        (validation.options.keys & [:only_integer, :equal_to, :less_than, :less_than_or_equal_to,
          :greater_than, :greater_than_or_equal_to]).each { |v|
            validator_klass = "::ValidatiousOnRails::Validatious::Numericality::#{v.to_s.classify}Validator".constantize
            value = validation.options[v] if validation.options[v].is_a?(::Numeric)
            validators << validator_klass.new(validation, value)
          }

        validators
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
        validators = []
        validators << Validatious::PresenceValidator.new(validation)
      end

      # Resolve validation from validates_uniqueness_of.
      #
      # TODO: Implement using RemoteValidator.
      #
      def uniqueness_of(validation)
        validators = []
        validators << Validatious::UniquenessValidator.new(validation)
      end

      # Unknown validations - if no matching custom validator is found/registered.
      #
      def method_missing(sym, *args, &block)
        ::ValidatiousOnRails.log "Unknown validation: #{sym}." <<
          " No custom Validatious validator found for this validation makro. " <<
          "Maybe you forgot to register you custom validation using: " <<
          "ValidatiousOnRails::ModelValidations.add(<CustomValidationClass>)", :warn
        nil
      end

      # TODO: Include custom validations here...
      #
      # @custom_validators.each { |validator_class| ... }

    end
  end
end
