# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

module ValidatiousOnRails
  module Validatious
    class UniquenessValidator < RemoteValidator

      def initialize(*args)
        super
        self.params = %w[]
        self.message = self.class.generate_message(:blank)
      end

    end
  end
end