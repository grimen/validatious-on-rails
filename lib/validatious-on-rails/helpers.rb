module ValidatiousOnRails
  module Helpers
    
    extend self
    
    # Helper for the layout to host the custom Validatious-validators for forms rendered.
    # This will only show up if the current view contains one - or more - forms that
    # are triggered to be validated with Validatous (i.e. ValidatiousOnRails that is).
    #
    def custom_validatious_validators
      if @content_for_validatious.present?
        content_tag(:script, @content_for_validatious,
          :type => 'text/javascript', :id => 'custom_validatious_validators')
      end
    end
    
  end
end

::ActionController::Base.helper ::ValidatiousOnRails::Helpers