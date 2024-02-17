require "active_storage/service"

class ActiveStorage::Service::SupabaseStorageService < ActiveStorage::Service
  def initialize(**config)
    @url = config[:url]
    @public_key = config[:public_key]
    @service_key = config[:service_key]
    @bucket_name = config[:bucket_name]
    @public = config[:public]
  end

  def upload(key, io, checksum: nil, **options)
    url = "#{@url}/storage/v1/object/#{@bucket_name}/#{key}"

    payload = {
      file: io
    }

    execute_request(:post, url, payload: payload, is_file_upload: true)
  end

  def download(key)
    url = @public ? "#{@url}/storage/v1/object/public/#{@bucket_name}/#{key}" : "#{@url}/storage/v1/object/authenticated/#{@bucket_name}/#{key}"

    execute_request(:get, url)
  end

  def delete(key)
    url = "#{@url}/storage/v1/object/#{@bucket_name}/#{key}"

    execute_request(:delete, url)
  end

  def delete_prefixed(prefix)
    url = "#{@url}/storage/v1/object/#{@bucket_name}"

    execute_request(:delete, url, payload: { prefix: [prefix] })
  end

  def exist?(key)
    url = "#{@url}/storage/v1/object/list/#{@bucket_name}"

    execute_request(:post, url, payload: { prefix: key, limit: 1 })
  end

  def url(key, **options)
    if @public
      "#{@url}/storage/v1/object/public/#{@bucket_name}/#{key}"
    else
      url = "#{@url}/storage/v1/object/sign/#{@bucket_name}/#{key}"

      execute_request(:post, url, payload: options)
    end
  end

  def execute_request(method, url, payload: {}, headers: {}, is_file_upload: false)
    default_headers = {
      'Content-Type': "application/json"
    }

    default_headers["Authorization"] = "Bearer #{@service_key}" unless @public

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
