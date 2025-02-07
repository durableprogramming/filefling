# frozen_string_literal: true

module Filefling
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class UploadError < Error; end
  class DownloadError < Error; end
  class BucketError < Error; end
  class CredentialsError < Error; end
  class FileNotFoundError < Error; end
  class InvalidParameterError < Error; end
end
