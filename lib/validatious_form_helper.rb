require 'validatious.rb'

#
# Tap into the built-in form helpers to add validatious class names from
# model validations.
#
# @author Christian Johansen (christian@cjohansen.no)
# @version 0.1 2008-10-28
#
module ActionView::Helpers::FormHelper
  #
  # Add validation class names to text fields
  #
  def text_field_with_validation(object_name, method, options = {})
    klass = object_name.classify.constantize
    options[:class] ||= ""
    validation = Validatious::Validation.from_active_record(object_name, method)

    # Loop validation and add/append pairs to options
    validation.each_pair do |attr, value|
      options[attr] ||= ""
      options[attr] += value

      # Shake out duplicates
      options[attr] = options[attr].split.uniq.join(" ")
    end

    text_field_without_validation(object_name, method, options)
  end

  alias_method_chain :text_field, :validation
end
