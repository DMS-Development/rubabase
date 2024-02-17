require 'singleton'

module Rubabase
  class Client
    include Singleton
    attr_accessor :configuration

    def initialize
      @configuration = Configuration.new
    end

    def self.configure
      yield instance.configuration if block_given?
    end
  end
end