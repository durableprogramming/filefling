# frozen_string_literal: true
#
require "test_helper"
require "filefling/uploader"

module Filefling
  class UploaderTest < Minitest::Test
    def setup
      @config = {
        "bucket" => "test-bucket",
        "region" => "us-east-1",
        "expires" => 24,
        "prefix" => "test/",
        "access_key_id" => "test-key",
        "secret_access_key" => "test-secret"
      }
      @file_path = create_temp_file
      @s3_client = mock
      @presigner = mock
      Aws::S3::Client.stubs(:new).returns(@s3_client)
      Aws::S3::Presigner.stubs(:new).returns(@presigner)
      @uploader = Filefling::Uploader.new(@config)
    end

    def teardown
      delete_temp_file(@file_path)
    end

    def test_upload_success
      expected_key = "test/12345678.txt"
      expected_url = "https://test-bucket.s3.amazonaws.com/#{expected_key}"
      
      SecureRandom.stubs(:hex).with(8).returns("12345678")
      
      @s3_client.expects(:put_object).with(
        bucket: "test-bucket",
        key: expected_key,
        body: instance_of(File)
      ).returns(true)
      
      @presigner.expects(:presigned_url).with(
        :get_object,
        bucket: "test-bucket",
        key: expected_key,
        expires_in: 24 * 3600
      ).returns(expected_url)

      result = @uploader.upload(@file_path)

      assert_equal expected_key, result[:key]
      assert_equal expected_url, result[:url]
      assert_equal "test-bucket", result[:bucket]
    end

    def test_upload_with_custom_prefix
      @config["prefix"] = "custom/path/"
      uploader = Filefling::Uploader.new(@config)
      expected_key = "custom/path/12345678.txt"
      expected_url = "https://test-bucket.s3.amazonaws.com/#{expected_key}"

      SecureRandom.stubs(:hex).with(8).returns("12345678")
      
      @s3_client.expects(:put_object).with(
        bucket: "test-bucket",
        key: expected_key,
        body: instance_of(File)
      ).returns(true)
      
      @presigner.expects(:presigned_url).with(
        :get_object,
        bucket: "test-bucket",
        key: expected_key,
        expires_in: 24 * 3600
      ).returns(expected_url)

      result = uploader.upload(@file_path)
      assert_equal expected_key, result[:key]
    end

    def test_upload_failure_raises_error
      @s3_client.expects(:put_object).raises(Aws::S3::Errors::ServiceError.new({}, "Upload failed"))

      assert_raises() do
        @uploader.upload(@file_path)
      end
    end

    def test_upload_preserves_file_extension
      file_path = create_temp_file
      File.rename(file_path, "#{file_path}.pdf")
      expected_key = "test/12345678.pdf"
      expected_url = "https://test-bucket.s3.amazonaws.com/#{expected_key}"

      SecureRandom.stubs(:hex).with(8).returns("12345678")
      
      @s3_client.expects(:put_object).with(
        bucket: "test-bucket",
        key: expected_key,
        body: instance_of(File)
      ).returns(true)
      
      @presigner.expects(:presigned_url).with(
        :get_object,
        bucket: "test-bucket",
        key: expected_key,
        expires_in: 24 * 3600
      ).returns(expected_url)

      result = @uploader.upload("#{file_path}.pdf")
      assert_equal expected_key, result[:key]
      delete_temp_file("#{file_path}.pdf")
    end

    def test_upload_with_no_prefix
      @config["prefix"] = ""
      uploader = Filefling::Uploader.new(@config)
      expected_key = "12345678.txt"
      expected_url = "https://test-bucket.s3.amazonaws.com/#{expected_key}"

      SecureRandom.stubs(:hex).with(8).returns("12345678")
      
      @s3_client.expects(:put_object).with(
        bucket: "test-bucket",
        key: expected_key,
        body: instance_of(File)
      ).returns(true)
      
      @presigner.expects(:presigned_url).with(
        :get_object,
        bucket: "test-bucket",
        key: expected_key,
        expires_in: 24 * 3600
      ).returns(expected_url)

      result = uploader.upload(@file_path)
      assert_equal expected_key, result[:key]
    end

    def test_upload_nonexistent_file
      assert_raises(Errno::ENOENT) do
        @uploader.upload("nonexistent/file.txt")
      end
    end
  end
end
