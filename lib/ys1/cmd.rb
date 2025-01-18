# frozen_string_literal: true

# YS1
module YS1
  # Cmd module
  module Cmd
    class << self
      # Displays usage instructions and exits the program.
      #
      # @param command [String] The name of the command being executed.
      # @param args [Array<String>] A list of arguments for the command. Defaults to an empty array.
      # @return [void] This method does not return, as it exits the program.
      def usage(command, *args)
        message = "Usage:\n  #{File.basename(command)}"
        message += " #{args.join(" ")}" unless args.empty?
        warn message
        exit 1
      end
    end
  end
end
