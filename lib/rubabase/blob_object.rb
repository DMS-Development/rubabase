module Rubabase
  class BlobObject
    def initialize(client: Rubabase::Client.instance, bucket_name: nil, object_key:)
      @client = client
      @bucket_name = bucket_name || client.configuration.bucket_name
      @object_key = object_key
    end

    def upload_private_object(file_path)
      url = "#{@client.url}/object/#{@bucket_name}/#{@object_key}"

      payload = {
        file: File.new(file_path, "rb")
      }

      execute_request(:post, url, payload: payload, is_file_upload: true)
    end

    def update_object(file_path)
      url = "#{@client.url}/object/#{@bucket_name}/#{@object_key}"

      payload = {
        file: File.new(file_path, "rb")
      }

      execute_request(:put, url, payload: payload, is_file_upload: true)
    end

    def retrieve_private_object
      url = "#{@client.url}/object/authenticated/#{@bucket_name}/#{@object_key}"

      execute_request(:get, url)
    end

    def retrieve_public_object
      url = "#{@client.url}/object/public/#{@bucket_name}/#{@object_key}"

      execute_request(:get, url, include_auth: false)
    end

    def delete_object
      url = "#{@client.url}/object/#{@bucket_name}/#{@object_key}"

      execute_request(:delete, url)
    end

    def generate_presigned_upload_url
      url = "#{@client.url}/object/upload/sign/#{@bucket_name}/#{@object_key}"

      execute_request(:post, url)
    end

    def upload_to_presigned_url(upload_url, file_path) end

    def execute_request(method, url, payload: {}, headers: {}, is_file_upload: false, include_auth: true)
      default_headers = {
        'Content-Type': "application/json"
      }

      default_headers["Authorization"] = "Bearer #{@client.service_key}" if include_auth

      if is_file_upload
        default_headers["Content-Type"] = "multipart/form-data"
        response = RestClient::Request.execute(
          method: method,
          url: url,
          payload: payload,
          headers: default_headers.merge(headers)
        )
      else
        response = RestClient::Request.execute(
          method: method,
          url: url,
          payload: payload.to_json,
          headers: default_headers.merge(headers)
        )
      end
      JSON.parse(response.body)
    end

  end
end

