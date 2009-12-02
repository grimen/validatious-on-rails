# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious client_side_validator]))
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious ajax_validator]))

module ValidatiousOnRails
  module Validators
    module NumericalityOf

      def self.validators_for(validation)
        validators = []
        validation.options[:allow_nil] = false if validation.options[:allow_nil].nil?

        if validation.options[:odd] && !validation.options[:even]
          validators << OddValidator.new(validation.options[:allow_nil], :message => :odd)
        end

        if validation.options[:even] && !validation.options[:odd]
          validators << EvenValidator.new(validation.options[:allow_nil], :message => :even)
        end

        if validation.options[:only_integer]
          validators << OnlyIntegerValidator.new(validation.options[:allow_nil], :message => :not_a_number)
        end

        (validation.options.keys & [:equal_to, :less_than, :less_than_or_equal_to,
        :greater_than, :greater_than_or_equal_to]).each { |name|
          validator_klass = "::#{self.name}::#{name.to_s.classify}Validator".constantize
          value = validation.options[name]
          if value.is_a?(::Numeric)
            validators << validator_klass.new(validation.options[name],
              validation.options[:allow_nil], :message => name)
          end
        }
        validators
      end

      class OddValidator < Validatious::ClientSideValidator
        def initialize(*args)
          self.params = %w[allow_nil]
          self.fn = %{
            #{self.class.handle_nil(0)}
            value = +value;
            return (value % 2) == 1;
          }
          super
        end
      end

      class EvenValidator < Validatious::ClientSideValidator
        def initialize(*args)
          self.params = %w[allow_nil]
          self.fn = %{
            #{self.class.handle_nil(0)}
            value = +value;
            return (value % 2) == 0;
          }
          super
        end
      end

      class OnlyIntegerValidator < Validatious::ClientSideValidator
        def initialize(*args)
          super
          self.params = %w[allow_nil]
          self.fn = %{
            #{self.class.handle_nil(0)}
            value = +value;
            return /^[+-]?\d+$/.test(value);
          }
          super
        end
      end

      class EqualToValidator < Validatious::ClientSideValidator
        def initialize(*args)
          super
          self.params = %w[count allow_nil]
          self.fn = %{
            #{self.class.handle_nil}
            value = +value;
            return value == params[0];
          }
          super
        end
      end

      class LessThanValidator < Validatious::ClientSideValidator
        def initialize(*args)
          self.params = %w[count allow_nil]
          self.fn = %{
            #{self.class.handle_nil}
            value = +value;
            return value < params[0];
          }
          super
        end
      end

      class LessThanOrEqualToValidator < Validatious::ClientSideValidator
        def initialize(*args)
          self.params = %w[count allow_nil]
          self.fn = %{
            #{self.class.handle_nil}
            value = +value;
            return value <= params[0];
          }
          super
        end
      end

      class GreaterThanValidator < Validatious::ClientSideValidator
        def initialize(*args)
          self.params = %w[count allow_nil]
          self.fn = %{
            #{self.class.handle_nil}
            value = +value;
            return value > params[0];
          }
          super
        end
      end

      class GreaterThanOrEqualToValidator < Validatious::ClientSideValidator
        def initialize(*args)
          self.params = %w[count allow_nil]
          self.fn = %{
            #{self.class.handle_nil}
            value = +value;
            return value >= params[0];
          }
          super
        end
      end

    end
  end
end
