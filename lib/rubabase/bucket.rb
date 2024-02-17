# module Rubabase
#   class Bucket
#     attr_reader :bucket_name
#     def initialize(bucket_name, client: Rubabase::Client.instance)
#       @bucket_name = client[bucket_name]
#       @client = client
#     end
#   end
# end