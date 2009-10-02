# encoding: utf-8
begin
  require 'validation_reflection'
rescue LoadError
  gem 'redinger-validation_reflection', '>= 0.3.2'
  require 'validation_reflection'
end

require File.join(File.dirname(__FILE__), *%w[validatious client_side_validator])

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

      #
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
            :validators => validation[:validators].compact.uniq.join(' ').gsub(/[\n]+/, '')
          )
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
            attribute_validation[:validators] << validation_options[:validator]
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

      #
      # Resolve validation from validates_acceptance_of.
      #
      # Note: acceptance_of <=> presence_of (for Validatious)
      #
      # TODO: Make this a custom validator - if the advanced options are set (:accept) (low-prio)
      #
      def acceptance_of(validation)
        {:class => 'required', :validator => nil}
      end

      #
      # Resolve validation from validates_associated.
      #
      # Note: Most probably too hard to implement on client-side at least.
      #
      def associated(validation)
        {:class => '', :validator => nil}
      end

      #
      # Resolve validation from validates_confirmation_of.
      #
      # Note: This validation is treated a bit differently in compare
      #       to the other validations. See "from_active_record".
      #
      def confirmation_of(validation)
        field_id_to_confirm = unless validation.active_record.present?
          "#{validation.active_record.name.tableize.singularize.gsub('/', '_')}_#{validation.name}"
        else
          "#{validation.name}"
        end
        {:class => "confirmation-of_#{field_id_to_confirm}", :validator => nil}
      end

      #
      # Resolve validation from validates_exclusion_of.
      #
      # Attaching custom validator - if not already defined.
      #
      def exclusion_of(validation)
        name, alias_name = validator_name(validation, :in)

        validator = returning Validatious::ClientSideValidator.new(name) do |v|
            v.accept_empty = validation.options[:allow_blank] || validation.options[:allow_nil]
            v.fn = %{
              var exclusion_values = #{validation.options[:in].to_json};
              for (var i = 0; i < exclusion_values.length; i++) {
                if (exclusion_values[i] == value) { return false; }
              };
              return true;
            }
            v.message = validation_error_message(validation)
            v.params = []
            v.aliases = [alias_name] - [name]
        end
        {:class => "#{name}", :validator => validator}
      end

      #
      # Resolve validation from validates_format_of.
      #
      # Attaching custom validator - only if identical format validator already exists,
      # otherwise refer to that one instead. Needs regex.inspect to get it right.
      #
      def format_of(validation)
        name, alias_name = validator_name(validation, :with, validation.options[:with].inspect)

        validator = returning Validatious::ClientSideValidator.new(name) do |v|
            v.accept_empty = validation.options[:allow_blank] || validation.options[:allow_nil]
            v.fn = %{
              var format_regex = #{validation.options[:with].inspect};
              return format_regex.test(value);
            }
            v.message = validator_error_message(validation)
            v.params = []
            v.aliases = [alias_name] - [name]
        end
        {:class => "#{name}", :validator => validator}
      end

      #
      # Resolve validation from validates_inclusion_of.
      #
      # Note: Attaching custom validator - if not already defined.
      #
      def inclusion_of(validation)
        name, alias_name = validator_name(validation, :in)

        validator = returning Validatious::ClientSideValidator.new(name) do |v|
            v.accept_empty = validation.options[:allow_blank] || validation.options[:allow_nil]
            v.fn = %{
              var inclusion_values = #{validation.options[:in].to_json};
              for (var i = 0; i < inclusion_values.length; i++) {
                if (inclusion_values[i] == value) { return true; }
              };
              return false;
            }
            v.message = validator_error_message(validation)
            v.params = []
            v.aliases = [alias_name] - [name]
        end
        {:class => "#{name}", :validator => validator}
      end

      #
      # Resolve validation from validates_length_of.
      #
      def length_of(validation)
        range = validation.options[:in] || validation.options[:within]
        min, max = range.min, range.max if range
        min ||= validation.options[:minimum] || validation.options[:is]
        max ||= validation.options[:maximum] || validation.options[:is]

        class_name = [
            ("min-length_#{min}" if min.present?),
            ("max-length_#{max}" if max.present?)
          ].compact.join(' ')

        {:class => class_name, :validator => nil}
      end
      alias :size_of :length_of

      #
      # Resolve validation from validates_numericality_of.
      #
      # TODO: Make this a custom validator - if the advanced options are set (:odd, :even, ...)
      #
      def numericality_of(validation)
        {:class => 'numeric', :validator => nil}
      end

      #
      # Resolve validation from validates_presence_of.
      #
      # Note: acceptance_of <=> presence_of (for Validatious)
      #
      def presence_of(validation)
        {:class => 'required', :validator => nil}
      end

      #
      # TODO: Resolve validation from validates_uniqueness_of.
      #
      # Note: Implement using .
      #
      def uniqueness_of(validation)
        {:class => '', :validator => nil}
      end

      #
      # Unknown validations - if no matching custom validator is found/registered.
      #
      def method_missing(sym, *args, &block)
        ::ValidatiousOnRails.log
          "Unknown validation: #{sym}. No custom Validatious validator found for this validation makro. " <<
          "Maybe you forgot to register you custom validation using: " <<
          "ValidatiousOnRails::ModelValidations.add(<CustomValidationClass>)", :warn
        {:class => '', :validator => nil}
      end

      # TODO: Include custom validations here
      # @custom_validators.each { |validator_class| extend validator_class }

      private

        # Generate a unique valdiator ID to avoid clashes.
        #
        # Note: Ruby #hash is way faster than SHA1 (etc.) - just replace any negative sign.
        #
        def validator_id(value)
          value.to_s.hash.to_s.tr('-', '1')
        end

        # Any named specified for this custom validation?
        # E.g. validates_format_of :name, :with => /\d{6}-\d{4}/, :name => 'ssn-se'
        #
        # If not, create one that's uniqe based on validation and what to validate based on,
        # e.g. validates_format_of :name, :with => /\d{6}-\d{4}/ # => :name => "format_with_#{hash-of-:with-value}"
        #
        def validator_name(validation, id_key, id_value = nil)
          # Avoiding duplicates...
          identifier = id_value.present? ? validator_id(id_value) : validator_id(validation.options[id_key])
          validator_id = "#{validation.macro.to_s.sub(/^validates_/, '').sub(/_of/, '')}_#{id_key}-#{identifier}"
          name = validation.options[:name].present? ? validation.options[:name] : validator_id
          # "_" is not allowed in name/alias(es) - used to seperate validator-id from it's args/params.
          [name, validator_id].collect! { |v| v.tr('_', '-') }
        end

        # Generate proper error message using explicit message, or I18n-lookup.
        # Core validations gets treated by Rails - unless explicit message is set that is.
        #
        def validator_error_message(validation)
          explicit_message = validation.options[:message]
          
          if explicit_message.present?
            if explicit_message.is_a?(::Symbol)
              ::I18n.t(explicit_message, :scope => :'activerecord.errors.messages',
                :default => "activerecord.errors.messages.#{explicit_message}")
            else
              explicit_message.to_s
            end
          else
            unless CORE_VALIDATIONS.include?(validation.macro.to_sym)
              # No core validation, try to make up a descent I18n lookup path using conventions.
              key = validation.macro.to_s.tr('-', '_').gsub(/^validates?_/, '').gsub(/_of/, '').to_sym
              ::I18n.t(key, :scope => :'activerecord.errors.messages',
                :default => "activerecord.errors.messages.#{key}")
            else
              # Nothing - let Rails rails handle the core validation message translations (I18n).
            end
          end
        end

    end
  end
end
