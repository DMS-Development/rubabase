require "rails/generators"

module Rubabase
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)
    def insert_supabase_configuration
      config_path = Rails.root.join("config", "storage.yml")

      if File.exist?(config_path)
        configuration = build_supabase_config

        append_configuration(config_path, configuration)

        say "A Supabase configuration has been added to config/storage.yml.", :green
        say "Please enable it as needed for each environment by adding `config.active_storage.service = :supabase` in
            config/environments/<environment>.rb".squish,
            :yellow

        instructions_for_credentials
        instructions_for_master_key
      else
        say "Couldn't find config/storage.yml.", :red
      end
    end

    def create_initializer_file
      template 'rubabase_initializer.rb.tt', 'config/initializers/rubabase.rb'
      say "Initializer created at config/initializers/rubabase.rb", :green
    end

    private

    def build_supabase_config
      bucket_type = ask('Is the bucket type private or public? Answer "private" or "public"')
      bucket_type_validated = bucket_type.downcase == 'public' ? 'true' : 'false'

      <<~YAML
        #Supabase Storage Configuration
        supabase:
          service: ActiveStorage::Service::SupabaseStorageService
          url: <%= Rails.application.credentials.dig(:supabase, :url) %>
          public_key: <%= Rails.application.credentials.dig(:supabase, :public_key) %>
          service_key: <%= Rails.application.credentials.dig(:supabase, :service_key) %>
          bucket_name: <%= Rails.application.credentials.dig(:supabase, :bucket_name) %>
          public: #{bucket_type_validated}
      YAML
    end

    def append_configuration(config_path, config_content)
      needs_newline = !File.read(config_path).empty?

      File.open(config_path, "a") do |file|
        file.puts "\n" if needs_newline
        file.write(config_content)
      end
    end

    def instructions_for_credentials
      say "\nTo set up these variables in encrypted credentials for both ActiveStorage and Supabase client functionality:", :cyan

      say <<~INSTRUCTIONS, :yellow
                1. Run `rails credentials:edit` to open the credentials file.
                2. Add the following entries:

                   supabase:
                     url: YOUR_SUPABASE_URL
                     public_key: YOUR_SUPABASE_PUBLIC_KEY
                     service_key: YOUR_SUPABASE_SERVICE_KEY
                     bucket_name: YOUR_SUPABASE_BUCKET_NAME

                3. Save and close the file. Now your credentials are saved securely and can be used by the 
application. You can start coding 😘
              #{"  "}
              Use actual keys in place of YOUR_SUPABASE_URL, YOUR_SUPABASE_PUBLIC_KEY, YOUR_SUPABASE_SERVICE_KEY and#{' '}
        YOUR_SUPABASE_BUCKET_NAME.\n
      INSTRUCTIONS
    end

    def instructions_for_master_key
      say "WARNING: The credentials are encrypted with a master key. Here are some instructions to manage it:", :red

      say <<-WARNING, :yellow
        1. The master key is stored in `config/master.key` file, do not commit this file to source control.
        2. Share this key securely with your teammates if they need to access the credentials.#{" "}
        3. In the production environment, you should set this key as an environment variable on the server.
        4. If you lose the key, you won't be able to access the credentials. It's very important to keep it safe.
      WARNING
    end
  end
end
