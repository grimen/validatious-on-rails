# encoding: utf-8

module ValidatiousOnRails
  module Helpers

    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    def attach_validator_for(object_name, method, options = {})
      options = ::ValidatiousOnRails::ModelValidations.options_for(object_name, method, options, @content_for_validatious)
      custom_js = options.delete(:js)
      content_for :validatious, custom_js if custom_js.present?
      options
    end

    # Helper for the layout to host the custom Validatious-validators for forms rendered.
    # This will only show up if the current view contains one - or more - forms that
    # are triggered to be validated with Validatous (i.e. ValidatiousOnRails that is).
    #
    def attached_validators
      if @content_for_validatious.present?
        content_tag(:script, @content_for_validatious,
          :type => 'text/javascript', :id => 'custom_validators')
      end
    end
    alias :javascript_for_validatious :attached_validators

    def self.extract_args!(*args)
      tail = []
      tail.unshift(args.pop) until args.blank? || args.last.is_a?(::Hash)
      unless args.last.is_a?(::Hash)
        args = tail
        tail = []
      end
      return args, tail
    end

    module ClassMethods
      
      def define_with_validatious_support(field_type)
        begin
          define_method :"#{field_type}_with_validation" do |*args|
            args, tail = ::ValidatiousOnRails::Helpers.extract_args!(*args)
            options = self.attach_validator_for(args.first, args.second, args.extract_options!)
            self.send :"#{field_type}_without_validation", *((args << options) + tail)
          end
          alias_method_chain field_type, :validation
        rescue
          # Rails version compability. Note: :respond_to? don't seems to work...
        end
      end

    end

  end
end

::ActionController::Base.helper ::ValidatiousOnRails::Helpers
