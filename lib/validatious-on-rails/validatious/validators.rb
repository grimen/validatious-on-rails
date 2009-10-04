Dir.glob(File.join(File.dirname(__FILE__), 'validators', '*.rb').to_s).each do |validator|
  require validator
end