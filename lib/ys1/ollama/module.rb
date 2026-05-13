# frozen_string_literal: true

require "json"

module YS1
  module Ollama
    # Ollama Module module
    module Module
      class << self
        # Builds the request payload for a non-streaming Ollama generation request
        #
        # @param prompt [String] the input prompt
        # @param data [Hash] the data parameter
        # @return [Hash] request body as a hash
        def ollama_request_data(prompt, data)
          req_data = JSON.parse(data.data.to_json)
          req_data["prompt"] = prompt
          req_data["stream"] = false
          req_data["options"] = data.options.data # Object."instance variable"."method"
          req_data
        end

        # Builds the request body for streaming chat
        #
        # @param prompt [String] the input prompt
        # @param data [Hash] the data parameter
        # @return [Hash] request body as a hash
        def request_body(prompt, data)
          req_data = JSON.parse(data.data.to_json)
          req_data["messages"] = [{ role: "user", content: prompt.to_s }]
          req_data["stream"] = true
          req_data["options"] = data.options.data # Object."instance variable"."method"
          req_data
        end

        # Initializes HTTP client
        #
        # @param url [URI]
        # @return [Net::HTTP]
        def build_http(url)
          http = Net::HTTP.new(url.host, url.port)
          http.read_timeout = nil
          http
        end

        # Builds HTTP POST request
        #
        # @param url [URI]
        # @param data [Hash]
        # @return [Net::HTTP::Post]
        def build_request(url, data)
          req = Net::HTTP::Post.new(url.path, { "Content-Type" => "application/json" })
          req.body = data.to_json
          req
        end

        # rubocop:disable Metrics/MethodLength

        # Executes streaming request and processes incoming chunks
        #
        # @param http [Net::HTTP]
        # @param request [Net::HTTP::Post]
        # @yieldparam chunk [String]
        # @return [String] full response
        def execute(http, request)
          full_response = String.new
          buffer = String.new
          http.request(request) do |res|
            validate!(res)

            res.read_body do |chunk|
              next unless chunk

              buffer << chunk

              done = consume_buffer?(buffer, full_response) do |content|
                yield content if block_given?
              end

              break if done
            end
          end

          full_response
        rescue StandardError => e
          puts "\n[FATAL ERROR] #{e.class}: #{e.message}"
          raise
        end
        # rubocop:enable Metrics/MethodLength

        private

        # Consumes buffered stream data line-by-line
        #
        # @param buffer [String]
        # @param full_response [String]
        # @yieldparam content [String]
        # @return [Boolean] whether streaming is complete
        def consume_buffer?(buffer, full_response)
          while (line = buffer.slice!(/.*\n/))
            next if line.strip.empty?

            done = handle_line?(line, full_response) do |content|
              yield content if block_given?
            end

            return true if done
          end

          false
        end

        # Processes a single JSON line from the stream
        #
        # @param line [String]
        # @param full_response [String]
        # @yieldparam content [String]
        # @return [Boolean] whether this line signals completion
        def handle_line?(line, full_response)
          json = parse_json(line)

          raise "Ollama Error: #{json["error"]}" if json["error"]

          if (content = json.dig("message", "content"))
            full_response << content
            print content
            $stdout.flush
            yield content if block_given?
          end

          json["done"] == true
        end

        # Safely parses JSON from a line
        #
        # @param line [String]
        # @return [Hash]
        # @raise [RuntimeError] if parsing fails
        def parse_json(line)
          JSON.parse(line)
        rescue JSON::ParserError => e
          raise "JSON Parse Error: #{e.message} | #{line.inspect}"
        end

        # Validates HTTP response status
        #
        # @param res [Net::HTTPResponse]
        # @return [void]
        # @raise [RuntimeError] if response is not successful
        def validate!(res)
          return if res.is_a?(Net::HTTPSuccess)

          raise "HTTP Error: #{res.code} #{res.message}"
        end
      end
    end
  end
end
