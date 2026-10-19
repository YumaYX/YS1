# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

require_relative "ollama/module"
require_relative "dynamic_object"

module YS1
  # Namespace for interacting with the Ollama API
  module Ollama
    # @return [String] Ollama generate endpoint
    GENERATE_URL = "http://localhost:11434/api/generate"
    # @return [String] Ollama chat endpoint
    CHAT_URL = "http://localhost:11434/api/chat"

    class << self
      # @return [DynamicObject] the data for requests
      attr_accessor :data

      # Sends a synchronous request to the Ollama generate endpoint
      #
      # @param prompt [String] the input prompt
      # @return [Net::HTTPResponse] raw HTTP response
      def request_response(prompt)
        url = URI.parse(GENERATE_URL)
        http = Net::HTTP.new(url.host, url.port)
        http.open_timeout = nil
        http.read_timeout = nil

        request = Net::HTTP::Post.new(url.path, { "Content-Type" => "application/json" })
        request.body = YS1::Ollama::Module.ollama_request_data(prompt, data).to_json

        http.request(request)
      end

      # Sends a request and extracts only the response text
      #
      # @param prompt [String] the input prompt
      # @return [String] generated response text
      def request(prompt)
        http_response = request_response(prompt)
        JSON.parse(http_response.body).fetch("response")
      end

      # Streams a response from the Ollama chat endpoint
      #
      # @param prompt [String] the input prompt
      # @yieldparam chunk [String] each streamed content chunk
      # @return [String] full accumulated response
      def stream(prompt, &on_chunk)
        url = URI.parse(CHAT_URL)
        http = YS1::Ollama::Module.build_http(url)
        request = YS1::Ollama::Module.build_request(url, YS1::Ollama::Module.request_body(prompt, data))
        YS1::Ollama::Module.execute(http, request, &on_chunk)
      end
    end

    # Default data
    self.data = Object.new
    data.extend(YS1::DynamicObject)
    data.model = "gemma4"

    # Default data options
    data.options = Object.new
    data.options.extend(YS1::DynamicObject)
  end
end

YS1::Ollama.stream(ARGV.first) if __FILE__ == $PROGRAM_NAME
