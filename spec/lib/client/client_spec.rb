require 'rspec'
require_relative '../lib/rubabase/client'

RSpec.describe Rubabase::Client do
  let(:client) { Rubabase::Client.instance }

  describe '#create_bucket' do
    it 'creates a new bucket' do
      response = client.create_bucket('test_bucket', 123, 2048, ['pdf', 'png'], is_public: false)
      expect(response).to be_a(Hash)
    end
  end

  describe '#update_bucket' do
    it 'updates an existing bucket' do
      response = client.update_bucket('test_bucket', 4096, ['pdf'], is_public: true)
      expect(response).to be_a(Hash)
    end
  end

  describe '#buckets' do
    it 'retrieves a list of all buckets' do
      response = client.buckets
      expect(response).to be_a(Hash)
    end
  end

  describe '#get_bucket' do
    it 'retrieves details of a single bucket' do
      response = client.get_bucket('test_bucket')
      expect(response).to be_a(Hash)
    end
  end

  describe '#empty_bucket' do
    it 'removes all files from a bucket' do
      response = client.empty_bucket('test_bucket')
      expect(response).to be_a(Hash)
    end
  end

  describe '#delete_bucket' do
    it 'deletes a bucket' do
      response = client.delete_bucket('test_bucket')
      expect(response).to be_a(Hash)
    end
  end
end