# frozen_string_literal: true
require "thor"
require "aws-sdk-s3"
module Filefling
  module CLI
    module Commands
      class CreateBucket < Thor::Group
        include Thor::Actions

        argument :bucket_name, type: :string, desc: "Name of the bucket to create"
        class_option :region, type: :string, desc: "AWS region"

        def create_bucket
          config = Filefling::Config.new(options)
          config.load
          s3_client = config.aws_client

          begin
            s3_client.create_bucket(
              bucket: bucket_name
            )

            # Block public access
            s3_client.put_public_access_block(
              bucket: bucket_name,
              public_access_block_configuration: {
                block_public_acls: true,
                ignore_public_acls: true,
                block_public_policy: true,
                restrict_public_buckets: true
              }
            )

            # Enable encryption
            s3_client.put_bucket_encryption(
              bucket: bucket_name,
              server_side_encryption_configuration: {
                rules: [
                  {
                    apply_server_side_encryption_by_default: {
                      sse_algorithm: "AES256"
                    },
                    bucket_key_enabled: true
                  }
                ]
              }
            )

            puts "Successfully created bucket: #{bucket_name} with secure defaults"
            puts "- Public access blocked"
            puts "- Default encryption enabled"

          rescue Aws::S3::Errors::ServiceError => e
            puts "Error creating bucket: #{e.message}"
            exit(1)
          end
        end

        def self.banner
          "filefling create_bucket BUCKET_NAME"
        end
      end
    end
  end
end
