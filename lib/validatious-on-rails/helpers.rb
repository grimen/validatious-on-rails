module ValidatiousOnRails
  module Helpers

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

  end
end

::ActionController::Base.helper ::ValidatiousOnRails::Helpers