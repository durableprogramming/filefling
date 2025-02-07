# frozen_string_literal: true

module Filefling
  module CLI
    module Commands
      class Delete < Thor::Group
        include Thor::Actions

        argument :key, type: :string, desc: "S3 object key to delete"

        def delete_file
          config = Filefling::Config.load
          s3_client = Aws::S3::Client.new(
            region: config.region,
            credentials: config.aws_credentials
          )

          begin
            s3_client.delete_object(
              bucket: config.bucket,
              key: key
            )
            puts "Successfully deleted #{key} from #{config.bucket}"
          rescue Aws::S3::Errors::ServiceError => e
            puts "Error deleting file: #{e.message}"
            exit(1)
          end
        end

        def self.banner
          "filefling delete S3_OBJECT_KEY"
        end
      end
    end
  end
end
