# encoding: utf-8

module ValidatiousOnRails
  class Controller < ::ActionController::Base

    # To validate, poll request:
    #
    #   /validates/uniqueness_of?model={MODEL_NAME}&attribute={ATTRIBUTE_NAME}&value={INPUT_VALUE}(&id=RECORD_ID)
    #
    # == Example:
    #
    #   /validates/uniqueness_of?model=article&attribute=title&value=hello123(&id=1)
    #
    def method_missing(action, *args, &block)
      action = action.to_s.tr('-', '_')
      ::ValidatiousOnRails.log "Remote validation called: #{action.inspect}, with params: #{params.inspect}", :info

      begin
        record_klass = "::#{params[:model].to_s.classify}".constantize
      rescue
        raise RemoteValidationInvalid, "Not a valid model: #{params[:model].inspect}"
      end

      if record_klass.blank? || params[:attribute].nil? ||
        record_klass.content_columns.collect { |c| c.name.to_sym }.include?(params[:attribute].to_sym) == false
        raise RemoteValidationInvalid, "Not a valid attribute for #{record_klass.inspect}: #{params[:attribute].inspect}"
      end

      # Only check for method matching: validates_*.
      if record_klass.present? && record_klass.respond_to?(:"validates_#{action}")
        if validator_klass = ::ValidatiousOnRails::Validators::Validatious::AjaxValidator.class_for(action)
          if record = record_for(record_klass)
            # Perform validation.
            validation_result = validator_klass.perform_validation(record, params[:attribute].to_sym, params[:value], params)
            ::ValidatiousOnRails.log "#{validator_klass} validation result: #{validation_result.to_s.upcase}. #{record_klass}##{params[:attribute]} => #{params[:value].inspect}", :info
            return render(:text => validation_result, :status => 200)
          else
            raise RemoteValidationInvalid, "Invalid record ID for class #{record_klass.inspect}: #{params[:id]}. No such record found."
          end
        else
          raise RemoteValidationInvalid, "No remote validator matching: #{validator_klass.inspect}."
        end
      else
        raise RemoteValidationInvalid, "#{record_klass} don't respond to: #{"validates_#{action}".inspect}."
      end
    rescue RemoteValidationInvalid => e
      return render(:text => false, :status => 405)
    end

    protected

      def record_for(record_klass)
        ((params[:id].present? && params[:id].to_i > 0) ? record_klass.find(params[:id]) : record_klass.new) rescue nil
      end

  end
end
