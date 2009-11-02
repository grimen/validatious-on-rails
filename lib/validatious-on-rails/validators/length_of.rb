# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious client_side_validator]))
require File.expand_path(File.join(File.dirname(__FILE__), *%w[validatious ajax_validator]))

module ValidatiousOnRails
  module Validators
    module LengthOf

      def self.validators_for(validation)
        validators = []
        validation.options[:allow_nil] = false if validation.options[:allow_nil].nil?
        validation.options[:allow_blank] = false if validation.options[:allow_blank].nil?

        if validation.options[:is].present?
          validators << IsValidator.new(validation.options[:is],
                                        (validation.options[:allow_nil] || false),
                                        (validation.options[:allow_blank] || false), :message => :wrong_length)
        elsif [:in, :within, :minimum, :maximum].any? { |k| validation.options[k].present? }
          validation.options[:within] ||= validation.options[:in]
          validation.options[:minimum] ||= validation.options[:within].min rescue nil
          validation.options[:maximum] ||= validation.options[:within].max rescue nil

          #debugger
          if validation.options[:minimum].present?
            validators << MinimumValidator.new(validation.options[:minimum],
                                               (validation.options[:allow_nil] || false),
                                               (validation.options[:allow_blank] || false), :message => :too_short)
          end

          if validation.options[:maximum].present?
            validators << MaximumValidator.new(validation.options[:maximum],
                                               (validation.options[:allow_nil] || false),
                                               (validation.options[:allow_blank] || false), :message => :too_long)
          end
        end
        validators
      end

      class IsValidator < Validatious::ClientSideValidator
        def initialize(*args)
          self.params = %w[count allow_nil allow_blank]
          self.fn = %{
            value += '';
            #{self.class.handle_nil(1)}
            #{self.class.handle_blank(2)}
            return value.length == params[0];
          }
          super *args
        end
      end

      class MinimumValidator < Validatious::ClientSideValidator
        def initialize(*args)
          self.params = %w[count allow_nil allow_blank]
          self.fn = %{
            value += '';
            #{self.class.handle_nil(1)}
            #{self.class.handle_blank(2)}
            return value.length >= params[0];
          }
          super *args
        end
      end

      class MaximumValidator < Validatious::ClientSideValidator
        def initialize(*args)
          self.params = %w[count allow_nil allow_blank]
          self.fn = %{
            value += '';
            #{self.class.handle_nil(1)}
            #{self.class.handle_blank(2)}
            return value.length <= params[0];
          }
          super *args
        end
      end

    end
  end
end
