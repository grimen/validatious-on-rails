#
# Validatious module.
#
# @author Christian Johansen (christian@cjohansen.no)
# @version 0.1 2008-10-28
#
module Validatious

  #
  # Validatious/rails validation translator
  #
  class Validation

    #
    # Groks rails validations, and is able to convert a rails validation to
    # a Validatious 2.0 compatible class string.
    #
    # Input may be an ActiveRecord class, a class name (string), or an object
    # name along with a method/field
    #
    # Returns a string that will be recognized by Validatious as a class name in
    # form markup.
    #
    def self.from_active_record(object_or_class, method)
      # Get class
      klass = object_or_class.to_s.classify.constantize
      options = { :class_name => "" }

      klass.reflect_on_validations_for(method).each do |validation|
        opts = self.send(validation.macro.sub(/^validates_/, ''), validation)
        options[:class_name] += " #{opts[:class_name]}"
      end

      options
    end

    #
    # Resolve validation from validates_acceptance_of
    #
    def self.acceptance_of(validation)
      { :class_name => "required" }
    end

    #
    # Resolve validation from validates_associated
    #
    def self.associated(validation)
      { :class_name => "" }
    end

    #
    # Resolve validation from validates_confirmation_of
    #
    def self.confirmation_of(validation)
        { :class_name => "" }
    end

    #
    # Resolve validation from validates_exclusion_of
    #
    def self.exclusion_of(validation)
      { :class_name => "" }
    end

    #
    # Resolve validation from validates_format_of
    #
    def format_of(validation)
      { :class_name => validation.options.key?(:name) ?
                         validation.options[:name] : "" }
    end

    #
    # Resolve validation from validates_inclusion_of
    #
    def self.inclusion_of(validation)
      { :class_name => "" }
    end

    #
    # Resolve validation from validates_length_of
    #
    def self.length_of(validation)
      range = validation.options[:in] || validation.options[:within]
      min, max = nil, nil
      min, max = range.min, range.max if range
      min ||= validation.options[:minimum]
      max ||= validation.options[:maximum]
      class_name = ""
      class_name += "min-length_#{min}" unless min.nil?
      class_name += " max-length_#{max}" unless max.nil?

      { :class_name => class_name }
    end

    #
    # Resolve validation from validates_numericality_of
    #
    def self.numericality_of(validation)
      { :class_name => "" }
    end

    #
    # Resolve validation from validates_presence_of
    #
    def self.presence_of(validation)
      { :class_name => "required" }
    end

    #
    # Resolve validation from validates_uniqueness_of
    #
    def self.uniqueness_of(validation)
      { :class_name => "" }
    end
  end
end
