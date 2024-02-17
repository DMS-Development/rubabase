# frozen_string_literal: true

require_relative "rubabase/version"
require_relative "rubabase/configuration"
require_relative "rubabase/client"
require_relative "rubabase/storage"
require_relative "rubabase/bucket"
require_relative "rubabase/blob_object"
require_relative "ActiveStorage/Service/supabase_storage_service"
require_relative "generators/rubabase/install/install_generator"



module Rubabase
  class Error < StandardError; end
  # Your code goes here...
end
