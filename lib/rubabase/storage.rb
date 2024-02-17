require "rest-client"
require "json"

module Rubabase
  class Storage
    def initialize(client: Rubabase::Client.instance)
      @client = client
    end

    # def bucket(bucket_name)
    #   Bucket.new(bucket_name, client: @client)
    # end

  end
end