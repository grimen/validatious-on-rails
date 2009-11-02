# encoding: utf-8
Dir.glob(File.join(File.dirname(__FILE__), 'rails', '*.rb').to_s).each do |file|
  require file
end