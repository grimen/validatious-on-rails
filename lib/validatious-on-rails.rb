# encoding: utf-8
require File.join(File.dirname(__FILE__), *%w[validatious-on-rails validatious])
require File.join(File.dirname(__FILE__), *%w[validatious-on-rails model_validations])
require File.join(File.dirname(__FILE__), *%w[validatious-on-rails rails])
require File.join(File.dirname(__FILE__), *%w[validatious-on-rails helpers])
require File.join(File.dirname(__FILE__), *%w[validatious-on-rails controller])

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