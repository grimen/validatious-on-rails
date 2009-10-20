# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. validator]))

module ValidatiousOnRails
  module Validatious
    class UniquenessValidator < RemoteValidator

      def initialize(validation, options = {})
        super
        self.accept_empty = false
      end

      class << self

        def generate_message(validation)
          super(validation, :key => :taken)
        end

      end

    end
  end
end