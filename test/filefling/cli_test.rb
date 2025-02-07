# frozen_string_literal: true

require "test_helper"
require "filefling/cli"

module Filefling
  class CLITest < Minitest::Test
    def setup
      @cli = Filefling::CLI::App.new
    end

    def test_cli_loads_commands
      commands = Filefling::CLI::App.commands
      assert_includes commands.keys, "upload"
      assert_includes commands.keys, "delete"
    end

    def test_upload_command_exists
      command = Filefling::CLI::App.commands["upload"]
      assert command
      assert_equal command.description, "Upload command"
    end

    def test_delete_command_exists
      command = Filefling::CLI::App.commands["delete"]
      assert command
      assert_equal command.description, "Delete command"
    end

    def test_upload_command_requires_file_path
      command_class = Filefling::CLI::Commands::Upload
      arguments = command_class.arguments
      assert_equal 1, arguments.size
      assert_equal "file_path", arguments.first.name
      assert_equal :string, arguments.first.type
    end

    def test_delete_command_requires_key
      command_class = Filefling::CLI::Commands::Delete
      arguments = command_class.arguments
      assert_equal 1, arguments.size
      assert_equal "key", arguments.first.name
      assert_equal :string, arguments.first.type
    end
  end
end
