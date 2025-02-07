# frozen_string_literal: true
require "aws-sdk-s3"
require "securerandom"
require "pathname"
require_relative 'config'
require_relative 'presigned_url_generator'

module Filefling
  class Uploader
    def initialize(config)
      @config        = Filefling::Config.new(config)
      @url_generator = Filefling::PresignedUrlGenerator.new(config)
    end

    def upload(file_path)
      file = Pathname.new(file_path)
      key = generate_key(file)
      
      s3_client = @config.aws_client
      
      begin
        File.open(file_path, "rb") do |file_obj|
          s3_client.put_object(
            bucket: @config["bucket"],
            key: key,
            body: file_obj
          )
        end
        
        url = @url_generator.generate_url(key)
        
        {
          key: key,
          url: url,
          bucket: @config["bucket"]
        }
      rescue Aws::S3::Errors::ServiceError => e
        raise UploadError, "Failed to upload file: #{e.message}"
      end
    end

    private

    def generate_key(file)
      extension = file.extname
      random_name = SecureRandom.hex(8)
      prefix = @config["prefix"].to_s
      prefix = prefix + "/" unless prefix.empty? || prefix.end_with?("/")
      
      "#{prefix}#{random_name}#{extension}"
    end
  end
end
