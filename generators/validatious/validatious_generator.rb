class ValidatiousGenerator < Rails::Generator::Base
  
  def manifest
    record do |m|
      m.template 'v2.standalone.full.min.js', File.join('public', 'javascripts', 'v2.standalone.full.min.js')
      m.template 'validatious_config.js', File.join('public', 'javascripts', 'validatious_config.js')
    end
  end
  
end