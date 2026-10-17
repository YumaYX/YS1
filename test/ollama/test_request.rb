# frozen_string_literal: true

require_relative "ollama_helper"

class TestYS1OllamaRequest < Minitest::Test
  def test_prompt
    result = YS1::Ollama.request(
      "hi",
      model: TEST_OLLAMA_MODEL,
      options: { num_ctx: 128, think: false }
    )
    assert_match(/hi|hello/, result.downcase)
  end
end
