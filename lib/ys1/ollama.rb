# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

require_relative "ollama/module"
require_relative "ollama/options"

module YS1
  # Namespace for interacting with the Ollama API
  module Ollama
    class << self
      # @return [String] the model name used for requests
      attr_accessor :model
      # @return [YS1::Ollama::Options] the options for requets
      attr_accessor :opts

      # Sends a synchronous request to the Ollama generate endpoint
      #
      # @param prompt [String] the input prompt
      # @return [Net::HTTPResponse] raw HTTP response
      def request(prompt)
        url = URI.parse("http://localhost:11434/api/generate")
        data = YS1::Ollama::Module.ollama_request_data(prompt, opts)

        http = Net::HTTP.new(url.host, url.port)
        http.open_timeout = nil
        http.read_timeout = nil

        request = Net::HTTP::Post.new(url.path, { "Content-Type" => "application/json" })
        request.body = data.to_json

        http.request(request)
      end

      # Sends a request and extracts only the response text
      #
      # @param prompt [String] the input prompt
      # @return [String] generated response text
      def request_response(prompt)
        http_response = YS1::Ollama.request(prompt)
        json = JSON.parse(http_response.body)

        json.fetch("response")
      end

      # Streams a response from the Ollama chat endpoint
      #
      # @param prompt [String] the input prompt
      # @yieldparam chunk [String] each streamed content chunk
      # @return [String] full accumulated response
      def stream(prompt, &on_chunk)
        url = URI.parse("http://localhost:11434/api/chat")

        http = YS1::Ollama::Module.build_http(url)
        request = YS1::Ollama::Module.build_request(url, YS1::Ollama::Module.request_body(prompt, opts))

        YS1::Ollama::Module.execute(http, request, &on_chunk)
      end
    end
    # Default model
    self.model = "gemma4"

    self.opts = YS1::Ollama::Options.new
    # default option values
    opts.add("num_ctx", 8192)
    opts.add("temperature", 0.8)
  end
end

# Example usage when run directly
if __FILE__ == $PROGRAM_NAME
  YS1::Ollama.model = "gemma3n"
  YS1::Ollama.opts.add("num_ctx", 1024)
             .add("temperature", 0.1)
  puts YS1::Ollama.request_response("hi")

  YS1::Ollama.model = "gemma3n"
  YS1::Ollama.opts.num_ctx = 768
  YS1::Ollama.opts.temperature = 0.3
  YS1::Ollama.stream("bye")
end
