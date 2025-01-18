# frozen_string_literal: true

require "net/http"
require "json"

# Module YS1 provides an HTTP client to handle HTTP requests and responses.
module YS1
  # The Http class handles HTTP GET requests and processes responses.
  class Http
    attr_reader :uri, :response, :url, :http, :response_body

    # Initializes the Http client with a given URI.
    # @param uri [String] The URI for the HTTP request.
    def initialize(uri)
      @url = URI.parse(uri)
      @http = Net::HTTP.new(url.host, url.port)
      @http.use_ssl = (url.scheme == "https")
    end

    # Sends an HTTP GET request to the specified URI.
    # @return [Http] Returns the instance with response and body populated.
    def request
      request = Net::HTTP::Get.new(@url)
      @response = @http.request(request)
      self
    end

    # Checks if the HTTP response code is in the 2xx range.
    # @return [Boolean] True if response code is 2xx, false otherwise.
    def rc2xx?
      response_code = @response.code.to_i
      response_code.between?(200, 299)
    end

    # Parses the JSON response body into a Ruby data structure.
    # @return [Object] The parsed JSON data.
    def json_to_data
      request
      JSON.parse(@response.body)
    end
  end
end
