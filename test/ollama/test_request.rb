# frozen_string_literal: true

require_relative "ollama_helper"

class TestYS1OllamaRequest < Minitest::Test
  def test_prompt
    YS1::Ollama.data.model = TEST_OLLAMA_MODEL
    YS1::Ollama.data.options.num_ctx = 128
    YS1::Ollama.data.options.think = false

    result = YS1::Ollama.request("hi")
    assert_match(/hi|hello/, result.downcase)
  end
end
