# frozen_string_literal: true

require "json"

require_relative "ollama/request"

module YS1
  # Namespace for interacting with the Ollama API.
  #
  # Every method is stateless: configuration such as the model name and model
  # options is passed per call, so separate features (OCR, translation, plain
  # requests) never contaminate each other.
  module Ollama
    # Default model name used when none is given.
    DEFAULT_MODEL = "gemma4"

    # Ollama generate endpoint.
    GENERATE_URL = "http://localhost:11434/api/generate"

    # Ollama chat endpoint.
    CHAT_URL = "http://localhost:11434/api/chat"

    class << self
      # Sends a synchronous request to the Ollama generate endpoint.
      #
      # @param prompt [String] the input prompt
      # @param model [String] model name
      # @param options [Hash] model options (e.g. `num_ctx`, `temperature`)
      # @param extra [Hash] additional top-level payload fields (e.g. `images`)
      # @return [Net::HTTPResponse] raw HTTP response
      #
      # @example
      #   response = YS1::Ollama.response("hi", model: "gemma4")
      #   response.code # => "200"
      def response(prompt, model: DEFAULT_MODEL, options: {}, **extra)
        body = Request.generate_body(prompt, model: model, options: options, **extra)

        Request.post(GENERATE_URL, body)
      end

      # Sends a request and extracts only the response text.
      #
      # @param prompt [String] the input prompt
      # @param model [String] model name
      # @param options [Hash] model options (e.g. `num_ctx`, `temperature`)
      # @param extra [Hash] additional top-level payload fields (e.g. `images`)
      # @return [String] generated response text
      #
      # @example
      #   YS1::Ollama.request("hi", model: "gemma4")
      #   # => "Hello! How can I help you today?"
      def request(prompt, model: DEFAULT_MODEL, options: {}, **extra)
        raw = response(prompt, model: model, options: options, **extra)

        JSON.parse(raw.body).fetch("response")
      end

      # Streams a response from the Ollama chat endpoint.
      #
      # @param prompt [String] the input prompt
      # @param model [String] model name
      # @param options [Hash] model options (e.g. `num_ctx`, `temperature`)
      # @param extra [Hash] additional top-level payload fields
      # @yieldparam chunk [String] each streamed content chunk
      # @return [String] full accumulated response
      #
      # @example
      #   YS1::Ollama.stream("hi", model: "gemma4") { |chunk| print chunk }
      #   # prints the response incrementally and returns the full text
      def stream(prompt, model: DEFAULT_MODEL, options: {}, **extra, &on_chunk)
        body = Request.chat_body(prompt, model: model, options: options, **extra)

        Request.stream(CHAT_URL, body, &on_chunk)
      end
    end
  end
end
