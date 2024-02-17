require "rest-client"
require "json"

module Rubabase
  class Storage
    def initialize(client)
      @client = client
    end

    def bucket(bucket_name)
      Bucket.new(@client, bucket_name)
    end


  end
end