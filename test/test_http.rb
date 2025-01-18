# frozen_string_literal: true

require_relative "helper"

class TestYS1Http < Minitest::Test
  def test_request
    uri = "https://yumayx.github.io/index.html"
    c = YS1::Http.new(uri).request
    assert(c.rc2xx?)
  end

  def test_response_to_json
    uri = "https://yumayx.github.io/works/app.json"
    data = YS1::Http.new(uri).json_to_data
    assert(data.instance_of?(Hash))
  end
end
