# frozen_string_literal: true

require "yaml"

module Filefling
  class Config
    DEFAULT_CONFIG = {
      "config_file_path" => "~/.filefling.yml",
      "bucket" => nil,
      "region" => "us-east-1",
      "expires" => 24,
      "prefix" => "",
      "secret_access_key" => nil,
      "access_key_id" => nil
    }.freeze

    DEFAULT_CONFIG.keys.each do |_|
      define_method _ do
        @config[_.to_s]
      end
      define_method "#{_}=" do |k,v|
        @config[k.to_s] = v
      end
    end

    class << self
      def load
        new.load
      end
    end

    def aws_client
      Aws::S3::Client.new(
        region: self["region"],
        credentials: self.aws_credentials
      )
    end
    def aws_credentials
      Aws::Credentials.new(
        @config['access_key_id'],
        @config['secret_access_key']
      )
    end

    def initialize(_)

      @config = if _.nil?
                  {}
                elsif _.kind_of?(Filefling::Config)
                  _.to_h
                else
                  _.transform_keys(&:to_s)
                end.dup 
    end

    def load

      @config = load_env_vars.merge(@config)
      @config = load_config_file(@config['config_file_path'] || DEFAULT_CONFIG['config_file_path']).merge(@config)
      @config = DEFAULT_CONFIG.dup.merge(@config)

      validate_config!(@config)
      self
    end

    def to_h
      @config
    end

    def [](_)
      @config[_.to_s]
    end

    def []=(k,v)
      @config[k.to_s]=v
    end

    private

    def load_config_file(path)
      config_file = File.expand_path(path)
      return {} unless File.exist?(config_file)

      YAML.load_file(config_file) || {}
    rescue StandardError => e
      warn "Warning: Error loading config file: #{e.message}"
      {}
    end

    def load_env_vars
      out = {}

      DEFAULT_CONFIG.each do |k,v|
        env_key = "FILEFLING_#{k.to_s.upcase}"
        if ENV[env_key]
          val = ENV[env_key]
          if v.kind_of?(Integer)
            val = val.to_i
          end
          out[k] = val
        end
      end

      out
    end


    def validate_config!(config)
      raise "AWS bucket name must be configured" if config["bucket"].nil?
      raise "Invalid expiration time" unless config["expires"].is_a?(Integer) && config["expires"].positive?
      raise "Invalid region" if config["region"].nil? || config["region"].empty?
    end
  end
end
