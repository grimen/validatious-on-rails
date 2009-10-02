# encoding: utf-8
require File.join(File.dirname(__FILE__), *%w[validatious-on-rails validatious])
require File.join(File.dirname(__FILE__), *%w[validatious-on-rails model_validations])
require File.join(File.dirname(__FILE__), *%w[validatious-on-rails rails])
require File.join(File.dirname(__FILE__), *%w[validatious-on-rails helpers])

module ValidatiousOnRails
  
  extend self
  
  class ValidatiousError < ::StandardError
    def initialize(message)
      ::Validatious.log message, :debug
      super message
    end
  end
  
  mattr_accessor :verbose
  
  @@verbose = ::Object.const_defined?(:RAILS_ENV) ? (::RAILS_ENV.to_sym == :development) : true
  
  def log(message, level = :info)
    return unless @@verbose
    level = :info if level.blank?
    @@logger ||= ::Logger.new(::STDOUT)
    @@logger.send(level.to_sym, message)
  end
  
  def custom_validators
    Helpers.custom_validatious_validators
  end
  alias :include_custom_validators :custom_validators
  ::ActionController::Base.helper_method :custom_validators, :include_custom_validators
  
end