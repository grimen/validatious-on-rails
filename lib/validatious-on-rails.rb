# encoding: utf-8
require File.join(File.dirname(__FILE__), *%w[validatious-on-rails validatious])
require File.join(File.dirname(__FILE__), *%w[validatious-on-rails model_validations])
require File.join(File.dirname(__FILE__), *%w[validatious-on-rails rails])
require File.join(File.dirname(__FILE__), *%w[validatious-on-rails helpers])
require File.join(File.dirname(__FILE__), *%w[validatious-on-rails controller])

module ValidatiousOnRails # :nodoc:

  extend self
  
  # Returns the environment of the Rails application,
  # if this is running in a Rails context.
  # Returns `nil` if no such environment is defined.
  #
  # @return [String, nil]
  def rails_env
    return ::Rails.env.to_s if defined?(::Rails.env)
    return RAILS_ENV.to_s if defined?(RAILS_ENV)
    return nil
  end

  # Standard error: Acts as base error class for the plugin.
  #
  class ValidatiousOnRailsError < ::StandardError
    def initialize(message)
      ::ValidatiousOnRails.log message, :error
      super message
    end
  end
  RemoteValidationInvalid = ::Class.new(::ValidatiousOnRails::ValidatiousOnRailsError)

  @@verbose = rails_env == nil ? true : (rails_env.to_sym == :development)
  @@client_side_validations_by_default = true
  @@remote_validations_enabled = false

  mattr_accessor  :verbose,
                  :client_side_validations_by_default,
                  :remote_validations_enabled

  # Logging helper: Internal debug-logging for the plugin.
  #
  def log(message, level = :info)
    return unless @@verbose
    level = :info if level.blank?
    @@logger ||= ::Logger.new(::STDOUT)
    @@logger.send(level.to_sym, "[validatious-on-rails:]  #{level.to_s.upcase}  #{message}")
  end

end
