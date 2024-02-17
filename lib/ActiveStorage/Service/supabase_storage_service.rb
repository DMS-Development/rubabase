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

  def download_chunk(key, range)
    content = download(key)
    content[range]
  end

  def compose(source_keys, destination_key)
    combined_content = source_keys.map { |key| download(key) + "\n" }.join

    upload(destination_key, StringIO.new(combined_content))
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
      public_url(key, **options)
    else
      private_url(key, **options)
    end
  end

  def url_for_direct_upload(key)
    url = "#{@url}/storage/v1/object/upload/sign/#{@bucket_name}/#{key}"

    response = execute_request(:post, url, force_auth_header: true)

    "#{@url}#{response["url"]}"
  end

  def custom_metadata_headers(metadata)
    {}
  end

  def execute_request(method, url, payload: {}, headers: {}, is_file_upload: false, force_auth_header: false)
    default_headers = {
      'Content-Type': "application/json"
    }

    default_headers["Authorization"] = "Bearer #{@service_key}" unless @public && !force_auth_header

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

  private

  def public_url(key, **)
    "#{@url}/storage/v1/object/public/#{@bucket_name}/#{key}"
  end

  def private_url(key, **options)
    url = "#{@url}/storage/v1/object/sign/#{@bucket_name}/#{key}"
    execute_request(:post, url, payload: options)
  end

end
