# frozen_string_literal: true

require "thor"
require "filefling/uploader"
require "filefling/config"

module Filefling
  module CLI
    module Commands
      class Upload < Thor::Group
        include Thor::Actions
        argument :file_path, type: :string

        class_option :bucket, type: :string, desc: "S3 bucket name"
        class_option :expires, type: :numeric, desc: "Link expiration time in hours"
        class_option :prefix, type: :string, desc: "Add prefix to uploaded filename"
        class_option :region, type: :string, desc: "AWS region"

        def upload
          config   = Filefling::Config.new(options)
          config.load
          uploader = Filefling::Uploader.new(config)

          begin
            unless File.exist?(file_path)
              say "Error: File not found: #{file_path}", :red
              exit 1
            end

            result = uploader.upload(file_path)
            say "Uploaded successfully!", :green
            say "Download link (expires in #{config.expires}h): #{result[:url]}"
          rescue StandardError => e
            say "Error: #{e.message}", :red
            exit 1
          end
        end
      end
    end
  end
end
