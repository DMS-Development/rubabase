# frozen_string_literal: true
module Rubabase
  class Configuration
    attr_accessor :project_url, :public_key, :service_key, :bucket_name, :bucket_private

    def initialize
      @project_url = ""
      @public_key = ""
      @service_key = ""
      @bucket_name = ""
      @bucket_private = ""
    end
  end
end
