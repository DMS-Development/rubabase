# frozen_string_literal: true
module Rubabase
  class Configuration
    attr_accessor :project_url, :public_key, :service_key

    def initialize
      @project_url = ""
      @public_key = ""
      @service_key = ""
    end
  end
end
