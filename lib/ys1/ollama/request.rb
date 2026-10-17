# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module YS1
  module Ollama
    # Builds and executes Ollama HTTP requests.
    #
    # This module is a low-level helper for {YS1::Ollama}. It knows nothing
    # about global configuration: every method receives what it needs
    # explicitly, so calls never leak state into one another.
    module Request
      class << self
        # Builds the payload for a non-streaming generation request.
        #
        # @param prompt [String] user input prompt
        # @param model [String] model name
        # @param options [Hash] model options (e.g. `num_ctx`, `temperature`)
        # @param extra [Hash] additional top-level payload fields (e.g. `images`)
        # @return [Hash] request payload
        #
        # @example
        #   YS1::Ollama::Request.generate_body("hi", model: "m")["stream"]
        #   # => false
        def generate_body(prompt, model:, options: {}, **extra)
          build_body(model, options, stream: false, prompt: prompt, **extra)
        end

        # Builds the payload for a streaming chat request.
        #
        # @param prompt [String] user input prompt
        # @param model [String] model name
        # @param options [Hash] model options (e.g. `num_ctx`, `temperature`)
        # @param extra [Hash] additional top-level payload fields
        # @return [Hash] request payload
        #
        # @example
        #   YS1::Ollama::Request.chat_body("hi", model: "m")["stream"]
        #   # => true
        def chat_body(prompt, model:, options: {}, **extra)
          build_body(
            model, options,
            stream: true,
            messages: [{ role: "user", content: prompt.to_s }],
            **extra
          )
        end

        # Sends a request and returns the raw HTTP response.
        #
        # @param url [String, URI::Generic] target endpoint
        # @param body [Hash] request payload
        # @return [Net::HTTPResponse] raw HTTP response
        def post(url, body)
          uri = to_uri(url)
          build_http(uri).request(build_request(uri, body))
        end

        # Sends a streaming request, yielding each content chunk.
        #
        # @param url [String, URI::Generic] target endpoint
        # @param body [Hash] request payload
        # @yieldparam content [String] streamed response content
        # @return [String] accumulated full response
        # @raise [RuntimeError] when the HTTP status or a JSON line is invalid
        def stream(url, body, &on_chunk)
          uri = to_uri(url)
          execute(build_http(uri), build_request(uri, body), &on_chunk)
        end

        private

        # Normalizes a URL into a URI object.
        #
        # @param url [String, URI::Generic] target endpoint
        # @return [URI::Generic] parsed URI
        def to_uri(url)
          url.is_a?(URI::Generic) ? url : URI.parse(url.to_s)
        end

        # Performs a streaming request, yielding each content chunk.
        #
        # @param http [Net::HTTP] configured HTTP client
        # @param request [Net::HTTP::Post] HTTP request
        # @yieldparam content [String] streamed response content
        # @return [String] accumulated full response
        def execute(http, request, &on_chunk)
          full = +""
          buffer = +""
          http.request(request) do |res|
            validate!(res)
            res.read_body { |chunk| process_chunk(chunk, buffer, full, &on_chunk) }
          end
          full
        end

        # Builds the common request payload.
        #
        # @param model [String] model name
        # @param options [Hash] model options
        # @param stream [Boolean] streaming mode flag
        # @param extra [Hash] additional payload fields
        # @return [Hash] merged payload
        def build_body(model, options, stream:, **extra)
          {
            "model" => model,
            "stream" => stream,
            "options" => options
          }.merge(extra.transform_keys(&:to_s))
        end

        # Builds a configured HTTP client.
        #
        # Read timeouts are disabled so that long-running generations are not
        # interrupted, while the default open timeout is preserved.
        #
        # @param url [URI::HTTP, URI::HTTPS] target endpoint
        # @return [Net::HTTP] configured HTTP client
        def build_http(url)
          Net::HTTP.new(url.host, url.port).tap do |http|
            http.read_timeout = nil
          end
        end

        # Builds an HTTP POST request with a JSON body.
        #
        # @param url [URI::HTTP, URI::HTTPS] target endpoint
        # @param body [Hash] request payload
        # @return [Net::HTTP::Post] HTTP request object
        def build_request(url, body)
          Net::HTTP::Post.new(
            url.path,
            { "Content-Type" => "application/json" }
          ).tap do |req|
            req.body = body.to_json
          end
        end

        # Processes streamed chunks line by line.
        #
        # @param chunk [String, nil] streamed chunk
        # @param buffer [String] streaming buffer
        # @param full_response [String] accumulated response
        # @yieldparam content [String] streamed content
        # @return [void]
        def process_chunk(chunk, buffer, full_response, &on_chunk)
          return unless chunk

          buffer << chunk

          while (line = buffer.slice!(/.*\n/))
            next if line.strip.empty?

            done = process_line?(line, full_response, &on_chunk)
            break if done
          end
        end

        # Processes a single streamed JSON line.
        #
        # @param line [String] JSON response line
        # @param full_response [String] accumulated response
        # @yieldparam content [String] streamed content
        # @return [Boolean] whether streaming is complete
        # @raise [RuntimeError] when Ollama returns an error
        def process_line?(line, full_response)
          json = parse_json(line)

          raise "Ollama Error: #{json["error"]}" if json["error"]

          content = json.dig("message", "content")
          if content
            full_response << content
            yield content if block_given?
          end

          json["done"] == true
        end

        # Parses a JSON response line safely.
        #
        # @param line [String] raw JSON string
        # @return [Hash] parsed JSON object
        # @raise [RuntimeError] when parsing fails
        def parse_json(line)
          JSON.parse(line)
        rescue JSON::ParserError => e
          raise "JSON Parse Error: #{e.message} | #{line.inspect}"
        end

        # Validates the HTTP response status.
        #
        # @param res [Net::HTTPResponse] HTTP response object
        # @return [void]
        # @raise [RuntimeError] when the response is unsuccessful
        def validate!(res)
          return if res.is_a?(Net::HTTPSuccess)

          raise "HTTP Error: #{res.code} #{res.message}"
        end
      end
    end
  end
end
