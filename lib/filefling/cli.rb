# frozen_string_literal: true

require "thor"
require "pathname"
require 'dry-inflector'

module Filefling
  module CLI
    class App < Thor
      def self.load_commands
        inflector = Dry::Inflector.new
        commands_path = File.join(__dir__, "cli", "commands", "*.rb")
        Dir[commands_path].each do |file|
          require file
          command_name = File.basename(file, ".rb")
          command_class = Commands.const_get(inflector.camelize(command_name))
          register(command_class, command_name, "#{command_name} [ARGS]", "#{command_name.capitalize} command")
        end
      end
    end
  end
end

Filefling::CLI::App.load_commands

Filefling::CLI::App.start(ARGV) if $PROGRAM_NAME == __FILE__
