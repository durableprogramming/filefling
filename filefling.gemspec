# frozen_string_literal: true

require_relative "lib/filefling/version"

Gem::Specification.new do |spec|
  spec.name = "filefling"
  spec.version = Filefling::VERSION
  spec.authors = ["Durable Programming Team"]
  spec.email = ["djberube@durableprogramming.com"]
  spec.summary = "Simple command-line tool for uploading files to S3 with generated download links"
  spec.description = "Filefling makes it easy to upload files to pre-configured S3 buckets. It generates random filenames and returns expiring download links for easy file sharing."
  spec.homepage = "https://github.com/durableprogramming/filefling"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/durableprogramming/filefling"
  spec.metadata["changelog_uri"] = "https://github.com/durableprogramming/filefling/blob/main/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk-s3", "~> 1.0"
  spec.add_dependency "securerandom", "> 0.1"
  spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "nokogiri", "> 1.0"
  spec.add_dependency "dry-inflector", "> 1.0"

  spec.add_development_dependency "minitest", "~> 5.16"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.metadata["rubygems_mfa_required"] = "true"
end
