# frozen_string_literal: true

# YS1
module YS1
  # Cmd module
  module Cmd
    class << self
      # Display usage information and exit the program.
      #
      # @param args [String] The usage information to display.
      # @return [void]
      def usage(commad, args)
        warn "Usage:\n  #{File.basename(commad)} #{args}"
        exit 1
      end
    end
  end
end
