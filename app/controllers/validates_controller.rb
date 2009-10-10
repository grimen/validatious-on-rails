# encoding: utf-8

class ValidatesController < ApplicationController

  # To validate, poll request:
  #
  #   /validates/uniqueness_of?model={MODEL_NAME}&attribute={ATTRIBUTE_NAME}&value={INPUT_VALUE}(&id=RECORD_ID)
  #
  # == Example:
  #
  #   /validates/uniqueness_of?model=article&attribute=title&value=hello123(&id=1)
  #
  def method_missing(action, *args, &block)
    begin
      record_klass = params[:model].to_s.classify.constantize
      attribute = params[:attribute].to_sym
      value = params[:value]
    rescue NameError
      # Can't cast: params[:model].
      ::ValidatiousOnRails.log "params[:model]=\"#{params[:model]}\" - not a valid model", :error
      return render(:text => false)
    rescue NoMethodError
      # Invalid value: params[:attribute].
      ::ValidatiousOnRails.log "params[:attribute]=\"#{params[:attribute]}\" - not a valid attribute for #{record_klass}", :error
      return render(:text => false)
    end

    # Only check for method matching: validates_*
    if klass.respond_to?(:"validates_#{action}")
      validator_klass_name = "#{action.to_s.gsub(/_of/, '')}Validator"
      remote_validators = ::Object.subclasses_of(::ValidatiousOnRails::Validatious::RemoteValidator)
      validator_klass = remote_validators.select { |v| v.to_s.split('::').last == validator_klass_name }.first

      if validator_klass.present?
         # Perform validation.
         record = params[:id].present? ? record_klass.find(params[:id]) : record_klass.new
         validation_result = validator_klass.fn(record, attribute, value)
         return render(:text => validation_result)
      else
         # Could not found matching remote validator.
        ::ValidatiousOnRails.log "No remote validator matching: #{validator_klass}", :debug
        return render(:text => false)
      end
    else
      ::ValidatiousOnRails.log "#{record_klass} don't respond to: validates_#{action}.", :debug
      return render(:text => 'Method not allowed', :status => 405)
    end
  end

end