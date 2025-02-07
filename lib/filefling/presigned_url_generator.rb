# frozen_string_literal: true
require "aws-sdk-s3"
require_relative "./config"

module Filefling
  class PresignedUrlGenerator
    def initialize(config)
      @config = Filefling::Config.new(config)
      @presigner = Aws::S3::Presigner.new(client: @config.aws_client)
    end

    def generate_url(key, expires_in: nil)
      expires_in ||= @config["expires"] * 3600
      
      @presigner.presigned_url(
        :get_object,
        bucket: @config["bucket"],
        key: key,
        expires_in: expires_in
      )
    end

    def generate_upload_url(key, expires_in: nil)
      expires_in ||= @config["expires"] * 3600

      @presigner.presigned_url(
        :put_object,
        bucket: @config["bucket"],
        key: key,
        expires_in: expires_in
      )
    end

    def generate_delete_url(key, expires_in: nil)
      expires_in ||= @config["expires"] * 3600

      @presigner.presigned_url(
        :delete_object,
        bucket: @config["bucket"],
        key: key,
        expires_in: expires_in
      )
    end
  end
end
