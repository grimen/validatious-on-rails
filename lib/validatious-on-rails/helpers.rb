module ValidatiousOnRails
  module Helpers

    def attach_validator_for(object_name, method, options = {})
      options = ::ValidatiousOnRails::ModelValidations.options_for(object_name, method, options, @content_for_validatious)
      content_for :validatious, options.delete(:js) if options[:js].present?
      options
    end

    class << self

      # Helper for the layout to host the custom Validatious-validators for forms rendered.
      # This will only show up if the current view contains one - or more - forms that
      # are triggered to be validated with Validatous (i.e. ValidatiousOnRails that is).
      #
      def attached_validators
        if @content_for_validatious.present?
          content_tag(:script, @content_for_validatious,
            :type => 'text/javascript', :id => 'custom_validatious_validators')
        end || ''
      end

      def extract_args!(*args)
        tail = []
        tail.unshift(args.pop) until args.blank? || args.last.is_a?(::Hash)
        unless args.last.is_a?(::Hash)
          args = tail
          tail = []
        end
        return args, tail
      end
    end

  end
end

::ActionController::Base.helper ::ValidatiousOnRails::Helpers