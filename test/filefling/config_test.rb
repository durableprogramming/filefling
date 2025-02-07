# frozen_string_literal: true
require "test_helper"
require "filefling/config"

module Filefling
  class ConfigTest < Minitest::Test
    def setup
      @original_env = ENV.to_h
      ENV.clear
      @config_file_path = create_temp_file(YAML.dump({
        "bucket" => "yaml-bucket",
        "region" => "us-west-2",
        "expires" => 48,
        "prefix" => "yaml-prefix/"
      }))
    end

    def teardown
      ENV.clear
      ENV.update(@original_env)
      delete_temp_file(@config_file_path)
    end

    def test_loads_default_config_values
      config = Filefling::Config.new({ "bucket"=> 'test'})
      config.stubs(:load_config_file).returns({})
      config.load

      assert_equal "us-east-1", config["region"]
      assert_equal 24, config["expires"]
      assert_equal "", config["prefix"]
    end

    def test_loads_config_from_yaml_file
      config = Filefling::Config.new({"config_file_path" => @config_file_path})
      config.load

      assert_equal "yaml-bucket", config["bucket"]
      assert_equal "us-west-2", config["region"]
      assert_equal 48, config["expires"]
      assert_equal "yaml-prefix/", config["prefix"]
    end

    def test_environment_variables_override_yaml
      ENV["FILEFLING_BUCKET"] = "env-bucket"
      ENV["FILEFLING_REGION"] = "eu-west-1"
      ENV["FILEFLING_EXPIRES"] = "12"
      ENV["FILEFLING_PREFIX"] = "env-prefix/"

      config = Filefling::Config.new({"config_file_path" => @config_file_path})
      config.load

      assert_equal "env-bucket", config["bucket"]
      assert_equal "eu-west-1", config["region"]
      assert_equal 12, config["expires"]
      assert_equal "env-prefix/", config["prefix"]
    end

    def test_constructor_options_override_environment
      ENV["FILEFLING_BUCKET"] = "env-bucket"
      
      config = Filefling::Config.new({
        "bucket" => "constructor-bucket",
        "config_file_path" => @config_file_path
      })
      config.load

      assert_equal "constructor-bucket", config["bucket"]
    end

    def test_validates_required_bucket
      config = Filefling::Config.new({})
      config.stubs(:load_config_file).returns({})

      assert_raises(RuntimeError, "AWS bucket name must be configured") do
        config.load
      end
    end

    def test_validates_expires_is_positive_integer
      config = Filefling::Config.new({
        "bucket" => "test-bucket",
        "expires" => -1
      })
      config.stubs(:load_config_file).returns({})

      assert_raises(RuntimeError, "Invalid expiration time") do
        config.load
      end
    end

    def test_validates_region_presence
      config = Filefling::Config.new({
        "bucket" => "test-bucket",
        "region" => ""
      })
      config.stubs(:load_config_file).returns({})

      assert_raises(RuntimeError, "Invalid region") do
        config.load
      end
    end

    def test_aws_credentials_creation
      ENV["AWS_ACCESS_KEY_ID"] = "test-key"
      ENV["AWS_SECRET_ACCESS_KEY"] = "test-secret"

      config = Filefling::Config.new({
        "bucket" => "test-bucket",
        "access_key_id" => "test-key",
        "secret_access_key" => "test-secret"
      })
      config.load

      credentials = config.aws_credentials
      assert_instance_of Aws::Credentials, credentials
      assert_equal "test-key", credentials.access_key_id
      assert_equal "test-secret", credentials.secret_access_key
    end

    def test_aws_client_creation
      config = Filefling::Config.new({
        "bucket" => "test-bucket",
        "region" => "us-east-1",
        "access_key_id" => "test-key",
        "secret_access_key" => "test-secret"
      })
      config.load

      client = config.aws_client
      assert_instance_of Aws::S3::Client, client
    end

    def test_handles_missing_config_file
      config = Filefling::Config.new({
        "bucket" => "test-bucket",
        "config_file_path" => "/nonexistent/path.yml"
      })

      config.load
      assert_equal "test-bucket", config["bucket"]
    end

    def test_handles_invalid_yaml_file
      invalid_yaml_path = create_temp_file("invalid: yaml: content: :")
      config = Filefling::Config.new({
        "bucket" => "test-bucket",
        "config_file_path" => invalid_yaml_path
      })

      config.load
      assert_equal "test-bucket", config["bucket"]
      delete_temp_file(invalid_yaml_path)
    end
  end
end
