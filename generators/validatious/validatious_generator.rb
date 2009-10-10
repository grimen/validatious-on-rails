# encoding: utf-8

class ValidatiousGenerator < Rails::Generator::Base
  
  def manifest
    record do |m|
      m.template 'v2.standalone.full.min.js', File.join('public', 'javascripts', 'v2.standalone.full.min.js')
      m.template 'validatious.config.js', File.join('public', 'javascripts', 'validatious.config.js')
      m.template 'initializer.rb', File.join('config', 'initializers', 'validatious-on-rails.rb')
    end
  end
  
end