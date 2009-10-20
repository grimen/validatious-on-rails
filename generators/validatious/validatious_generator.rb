# encoding: utf-8

class ValidatiousGenerator < Rails::Generator::Base
  
  def manifest
    record do |m|
      m.template 'initializer.rb',            File.join(*%[config initializers validatious-on-rails.rb])
      m.template 'XMLHttpRequest.js',         File.join(*%[public javascripts XMLHttpRequest.js])
      m.template 'v2.standalone.full.min.js', File.join(*%[public javascripts v2.standalone.full.min.js])
      m.template 'v2.config.js',              File.join(*%[public javascripts v2.config.js])
      m.template 'v2.rails.js',               File.join(*%[public javascripts v2.rails.js])
    end
  end
  
end