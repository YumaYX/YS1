# frozen_string_literal: true

require "rake"

module YS1
  # Module to list and format files in the current project directory.
  module ListFiles
    # Command-line interface for listing files and outputting them in a formatted text file.
    class CLI
      ##
      # Runs the CLI task: gathers files, filters them, formats them,
      # writes output to `listfiles.md`.
      #
      # @return [void]
      def run
        files = filtered_files

        File.open("listfiles.md", "w") do |file|
          file.puts(formatted_file_list(files))
          files.each { |f| file.puts(YS1::ListFiles.text_format(f)) }
        end
      end

      private

      ##
      # Retrieves all regular files in the project, excluding those listed in `.listfilesignore`.
      #
      # @return [Array<String>] filtered file paths
      def filtered_files
        all_files = FileList["**/**"].select { |f| File.file?(f) }
        excluded_files = ignore_list
        all_files.exclude(excluded_files)
      end

      ##
      # Reads ignore list from `.listfilesignore` file, if it exists.
      #
      # @return [Array<String>] list of file paths to ignore
      def ignore_list
        return [] unless File.exist?(".listfilesignore")

        File.readlines(".listfilesignore", chomp: true)
      end

      ##
      # Formats a list of files with markdown-style bullet points.
      #
      # @param files [Array<String>] list of file paths
      # @return [Array<String>] formatted list entries
      def formatted_file_list(files)
        files.map { |f| "- #{f}" }
      end
    end

    class << self
      ##
      # Formats the contents of a file into a markdown section. If the file is binary,
      # only the header is shown.
      #
      # @param path [String] path to the file
      # @return [String] markdown-formatted content
      def text_format(path)
        sample = File.open(path, "rb") { |f| f.read(1024) || "" }
        content = sample.include?("\x00") ? "" : File.read(path)

        <<~MARKDOWN

          ---

          # file name : #{path}

          #{content}
        MARKDOWN
      end
    end
  end
end
