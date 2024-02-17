require 'singleton'

module Rubabase
  class Client
    include Singleton

    attr_reader :configuration

    def initialize
      @configuration = Configuration.new
    end

    def self.configure
      yield instance.configuration if block_given?
    end
  end

  # `create_bucket` is a method to create a new bucket.
  # The new bucket's parameters will be sent in the request's payload.
  #
  # @param name [String] The name of the new bucket.
  # @param id [String/Integer] The unique identifier for the new bucket.
  # @param file_size_limit [Integer] The maximum file size that can be uploaded to the bucket in Kilobyts.
  #    Defaults to 0KB, meaning no limit.
  # @param allowed_file_types [Array] The types of files that can be uploaded to the bucket.
  #    These should be indicated as MIME types, and can include wildcards (e.g., "image/*").
  #    Defaults to an empty array, meaning all file types are allowed.
  # @param is_public [Boolean] Whether the bucket is public. Defaults to true.
  #
  # @example
  #    create_bucket("test_bucket", 123, file_size_limit: 2048, allowed_file_types: ["pdf", "png"], is_public: false)
  #
  # @return [Hash] The JSON parsed response from the request.
  #
  def create_bucket(name, id, file_size_limit = 0, allowed_file_types = [], is_public: true)
    payload = {
      name: name,
      id: id,
      is_public: is_public,
      file_size_limit: file_size_limit,
      allowed_file_types: allowed_file_types,
    }

    execute_request(:post, "#{@client.url}/bucket/", payload: payload)
  end

  # `update_bucket` is a method to modify an existing bucket's parameters.
  # Updated parameters will be sent in the request's payload.
  #
  # @param name [String] The name of the bucket to update.
  # @param file_size_limit [Integer] The new maximum file size that can be uploaded to the bucket in Kilobytes.
  #    Defaults to 0KB, meaning no limit.
  # @param allowed_file_types [Array] The new types of files that can be uploaded to the bucket.
  #    Defaults to an empty array, meaning all file types are allowed.
  # @param is_public [Boolean] Whether the bucket is public. Defaults to true.
  #
  # @example
  #    update_bucket("test_bucket", file_size_limit: 4096, allowed_file_types: ["pdf"], is_public: true)
  #
  # @return [Hash] The JSON parsed response from the request.
  #
  def update_bucket(name, file_size_limit = 0, allowed_file_types = [], is_public: true)
    payload = {
      is_public: is_public,
      file_size_limit: file_size_limit,
      allowed_file_types: allowed_file_types
    }

    execute_request(:put, "#{@client.url}/bucket/#{name}/", payload: payload)
  end

  # `buckets` retrieves a list of all buckets.
  #
  # @example
  #    buckets
  #
  # @return [Hash] The JSON parsed response from the request, containing the list of all buckets.
  #
  def buckets
    execute_request(:get, "#{@client.url}/bucket/")
  end

  # `get_bucket` takes the name of a bucket to retrieve a single bucket's details.
  #
  # @param name [String] The name of the bucket to retrieve.
  #
  # @example
  #    get_bucket("test_bucket")
  #
  # @return [Hash] The JSON parsed response from the request, containing the bucket's details.
  def get_bucket(name)
    execute_request(:get, "#{@client.url}/bucket/#{name}/")
  end

  # `empty_bucket` takes a name of a bucket to remove all files from a bucket, but not the bucket itself.
  #
  # @param name [String] The name of the bucket to empty.
  #
  # @example
  #    empty_bucket("test_bucket")
  #
  # @return [Hash] The JSON parsed response from the request.
  def empty_bucket(name)
    execute_request(:post, "#{@client.url}/storage/v1/bucket/#{name}/")
  end

  # `delete_bucket` takes a name of a bucket as a parameter, sends a POST request and deletes the named bucket.
  #
  # @param name [String] The name of the bucket to delete.
  #
  # @example
  #    delete_bucket("test_bucket")
  #
  # @return [Hash] The JSON parsed response from the request.
  def delete_bucket(name)
    execute_request(:delete, "#{@client.url}/bucket/#{name}/")
  end

  # `execute_request` is a method that sends an HTTP request and returns the response.
  # It also uses RestClient to handle the request and parse the response.
  #
  # @param method [Symbol] the HTTP method to be used (:get, :post, :delete, etc.).
  # @param url [String] the URL path where the request would be sent.
  # @param payload [Hash] key-value pairs that should be sent in a request body.
  #    Defaults to an empty hash.
  # @param headers [Hash] additional headers to include in the request.
  #    Defaults to an empty hash.
  #
  # The `Content-Type` is set to `application/json` by default, and `Authorization`
  # is set to a Bearer token stored in `@client.service_key`.
  # RestClient::Request.execute is used to execute the request with provided
  # method, url, converted to json payload and headers merged with default ones.
  # The response from the request is parsed from JSON format.
  #
  # @example
  #    execute_request(:post, "http://example.com/api/v1/test", payload: { name: "test" }, headers: { 'Accept': "application/json" })
  #
  # @return [Hash] the JSON parsed response from the request.
  #    The response has to be a valid JSON, otherwise, an error will be raised.
  #
  # @raise [RestClient::ExceptionWithResponse] if the request fails for any reason.
  # @raise [JSON::ParserError] if the response cannot be parsed into JSON.
  def execute_request(method, url, payload: {}, headers: {})
    default_headers = {
      'Content-Type': "application/json",
      'Authorization': "Bearer #{@client.service_key}"
    }
    response = RestClient::Request.execute(
      method: method,
      url: url,
      payload: payload.to_json,
      headers: default_headers.merge(headers)
    )
    JSON.parse(response)
  end

end