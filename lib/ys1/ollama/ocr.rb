# frozen_string_literal: true

require "base64"
require_relative "../ollama"

module YS1
  # Ollama
  module Ollama
    # Ollama OCR
    extend YS1::Ollama

    # Handles image processing using Ollama for Optical Character Recognition (OCR).
    module OCR
      # The prompt used for requesting text extraction from the image.
      PROMPT = "Just answer with the text in the image."

      # Class methods for handling image encoding and initiating the OCR request.
      class << self
        # Encodes a local image file into a Base64 string.
        #
        # @param path [String] The file path to the image.
        # @return [String] The Base64 encoded string of the image.
        def encode_image(path)
          File.binread(path).then do |bin|
            Base64.strict_encode64(bin)
          end
        end

        # Reads an image file, encodes it, sets up the context, and calls the Ollama API
        # to perform OCR.
        #
        # @param file_name [String] The file path to the image.
        def from_file(file_name)
          image_b64 = YS1::Ollama::OCR.encode_image(file_name)

          YS1::Ollama.data.images = [image_b64]
          YS1::Ollama.data.options.num_ctx = 8196
          YS1::Ollama.data.options.temperature = 0.1
          YS1::Ollama.request_response(YS1::Ollama::OCR::PROMPT)
        end
      end
    end
  end
end

# Executes the OCR process if the script is run directly, using the first command-line argument as the image path.
puts YS1::Ollama::OCR.from_file(ARGV.first) if __FILE__ == $PROGRAM_NAME
