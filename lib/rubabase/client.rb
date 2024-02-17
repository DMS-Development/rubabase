module Rubabase
  class Client
    attr_accessor :url, :public_key, :service_key

    def initialize(configuration)
      @url = configuration[:url]
      @public_key = configuration[:public_key]
      @service_key = configuration[:service_key]
    end
  end
end