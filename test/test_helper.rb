# frozen_string_literal: true

require "minitest/autorun"
require 'mocha/minitest'
require "filefling"
require "fileutils"
require "yaml"

module TestHelper
  def setup_test_config
    @test_config = {
      "bucket" => "test-bucket",
      "region" => "us-east-1",
      "expires" => 24,
      "prefix" => "test/"
    }

    ENV["AWS_ACCESS_KEY_ID"] = "test_key"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test_secret"
    ENV["FILEFLING_BUCKET"] = "test-bucket"
  end

  def teardown_test_config
    ENV.delete("AWS_ACCESS_KEY_ID")
    ENV.delete("AWS_SECRET_ACCESS_KEY")
    ENV.delete("FILEFLING_BUCKET")
  end

  def create_temp_file(content = "test content")
    file = Tempfile.new(["test", '.txt'])
    file.write(content)
    file.close
    file.path
  end

  def delete_temp_file(path)
    File.unlink(path) if path && File.exist?(path)
  end
end

module Minitest
  class Test
    include TestHelper
  end
end
