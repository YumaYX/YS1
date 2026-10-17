# frozen_string_literal: true

require "base64"
require_relative "../ollama"

module YS1
  # Ollama
  module Ollama
    # Handles image processing using Ollama for Optical Character Recognition (OCR).
    module OCR
      # The prompt used for requesting text extraction from the image.
      PROMPT = "Just answer with the text in the image."

      # Default model options tuned for OCR.
      DEFAULT_OPTIONS = { num_ctx: 8196, temperature: 0.1 }.freeze

      # Class methods for handling image encoding and initiating the OCR request.
      class << self
        # Encodes a local image file into a Base64 string.
        #
        # @param path [String] The file path to the image.
        # @return [String] The Base64 encoded string of the image.
        def encode_image(path)
          Base64.strict_encode64(File.binread(path))
        end

        # Reads an image file, encodes it, and calls the Ollama API to perform OCR.
        #
        # OCR-specific options are passed explicitly, so they never affect other
        # Ollama calls.
        #
        # @param file_name [String] The file path to the image.
        # @param model [String] model name used for the request
        # @param options [Hash] extra model options merged over the OCR defaults
        # @return [String] extracted text
        #
        # @example
        #   YS1::Ollama::OCR.from_file("scan.png")
        #   # => "Invoice #123"
        def from_file(file_name, model: YS1::Ollama::DEFAULT_MODEL, options: {})
          YS1::Ollama.request(
            PROMPT,
            model: model,
            options: DEFAULT_OPTIONS.merge(options),
            images: [encode_image(file_name)]
          )
        end
      end
    end
  end
end
