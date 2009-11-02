# encoding: utf-8
Dir.glob(File.join(File.dirname(__FILE__), 'validatious-on-rails', '*.rb').to_s).each do |file|
  require file
end

module ValidatiousOnRails # :nodoc:

  extend self

  # Standard error: Acts as base error class for the plugin.
  #
  class ValidatiousOnRailsError < ::StandardError
    def initialize(message)
      ::ValidatiousOnRails.log message, :error
      super message
    end
  end
  RemoteValidationInvalid = ::Class.new(::ValidatiousOnRails::ValidatiousOnRailsError)

  @@verbose = ::Object.const_defined?(:RAILS_ENV) ? (::RAILS_ENV.to_sym == :development) : true
  @@client_side_validations_by_default = true
  @@fallback_on_ajax_by_default = true

  mattr_accessor  :verbose,
                  :client_side_validations_by_default,
                  :fallback_on_ajax_by_default

  alias :client_side_validations_by_default? :client_side_validations_by_default
  alias :fallback_on_ajax_by_default? :fallback_on_ajax_by_default

  # Logging helper: Internal debug-logging for the plugin.
  #
  def log(message, level = :info)
    return unless @@verbose
    level = :info if level.blank?
    @@logger ||= ::Logger.new(::STDOUT)
    @@logger.send(level.to_sym, "[validatious-on-rails:]  #{level.to_s.upcase}  #{message}")
  end

end