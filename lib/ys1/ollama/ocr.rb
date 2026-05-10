# frozen_string_literal: true

require 'base64'
require_relative '../ollama'

module YS1
  module Ollama
    # Ollama OCR
    extend YS1::Ollama

    module OCR
      PROMPT = "Just answer with the text in the image."

      class << self
        def encode_image(path)
          File.binread(path).then do |bin|
            Base64.strict_encode64(bin)
          end
        end

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

puts YS1::Ollama::OCR.from_file(ARGV.first) if __FILE__ == $PROGRAM_NAME
