# frozen_string_literal: true

require "json"

module YS1
  module Ollama
    # Ollama request/stream utility module
    module Module
      class << self
        # Builds payload for non-streaming generation requests.
        #
        # @param prompt [String] user input prompt
        # @param data [Object] request configuration object
        # @return [Hash] request payload
        def ollama_request_data(prompt, data)
          build_payload(data, stream: false, prompt: prompt)
        end

        # Builds payload for streaming chat requests.
        #
        # @param prompt [String] user input prompt
        # @param data [Object] request configuration object
        # @return [Hash] request payload
        def request_body(prompt, data)
          build_payload(
            data,
            stream: true,
            messages: [{ role: "user", content: prompt.to_s }]
          )
        end

        # Initializes HTTP client.
        #
        # @param url [URI::HTTP, URI::HTTPS] target endpoint
        # @return [Net::HTTP] configured HTTP client
        def build_http(url)
          Net::HTTP.new(url.host, url.port).tap do |http|
            http.read_timeout = nil
          end
        end

        # Builds HTTP POST request.
        #
        # @param url [URI::HTTP, URI::HTTPS] target endpoint
        # @param data [Hash] request body
        # @return [Net::HTTP::Post] HTTP request object
        def build_request(url, data)
          Net::HTTP::Post.new(
            url.path,
            { "Content-Type" => "application/json" }
          ).tap do |req|
            req.body = data.to_json
          end
        end

        # rubocop:disable Metrics/MethodLength

        # Executes streaming request and processes response chunks.
        #
        # @param http [Net::HTTP] configured HTTP client
        # @param request [Net::HTTP::Post] HTTP request
        # @yieldparam content [String] streamed response content
        # @return [String] accumulated full response
        # @raise [RuntimeError] when HTTP or JSON parsing fails
        def execute(http, request)
          full_response = +""
          buffer = +""

          http.request(request) do |res|
            validate!(res)

            res.read_body do |chunk|
              process_chunk(chunk, buffer, full_response) do |content|
                yield content if block_given?
              end
            end
          end

          full_response
        rescue StandardError => e
          puts "\n[FATAL ERROR] #{e.class}: #{e.message}"
          raise
        end
        # rubocop:enable Metrics/MethodLength

        private

        # Builds common request payload.
        #
        # @param data [Object] request configuration object
        # @param stream [Boolean] streaming mode flag
        # @param extra [Hash] additional payload fields
        # @return [Hash] merged payload
        def build_payload(data, stream:, **extra)
          JSON.parse(data.data.to_json).merge(
            {
              "stream" => stream,
              "options" => data.options.data
            }.merge(extra.transform_keys(&:to_s))
          )
        end

        # Processes streamed chunks line-by-line.
        #
        # @param chunk [String, nil] streamed chunk
        # @param buffer [String] streaming buffer
        # @param full_response [String] accumulated response
        # @yieldparam content [String] streamed content
        # @return [void]
        def process_chunk(chunk, buffer, full_response)
          return unless chunk

          buffer << chunk

          while (line = buffer.slice!(/.*\n/))
            next if line.strip.empty?

            done = process_line?(line, full_response) do |content|
              yield content if block_given?
            end

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

          append_content(json, full_response) do |content|
            yield content if block_given?
          end

          json["done"] == true
        end

        # Appends streamed content to response buffer.
        #
        # @param json [Hash] parsed JSON response
        # @param full_response [String] accumulated response
        # @yieldparam content [String] streamed content
        # @return [void]
        def append_content(json, full_response)
          content = json.dig("message", "content")
          return unless content

          full_response << content

          print content
          $stdout.flush

          yield content if block_given?
        end

        # Parses JSON response line safely.
        #
        # @param line [String] raw JSON string
        # @return [Hash] parsed JSON object
        # @raise [RuntimeError] when parsing fails
        def parse_json(line)
          JSON.parse(line)
        rescue JSON::ParserError => e
          raise "JSON Parse Error: #{e.message} | #{line.inspect}"
        end

        # Validates HTTP response status.
        #
        # @param res [Net::HTTPResponse] HTTP response object
        # @return [void]
        # @raise [RuntimeError] when response is unsuccessful
        def validate!(res)
          return if res.is_a?(Net::HTTPSuccess)

          raise "HTTP Error: #{res.code} #{res.message}"
        end
      end
    end
  end
end
