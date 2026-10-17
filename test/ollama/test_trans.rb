# frozen_string_literal: true

require_relative "ollama_helper"

class TestYS1OllamaTrans < Minitest::Test
  def test_trans_prompt
    prompt = YS1::Ollama::Trans.prompt_template(:English, "text")
    assert_match(/text/, prompt)
    assert_match(/translate into English/, prompt)
  end

  def test_trans_into_ja
    en = YS1::Ollama::Trans.into(
      :English,
      "こんにちは",
      model: TEST_OLLAMA_MODEL,
      options: { num_ctx: 128, think: false }
    )
    assert_match(/hi|hello/, en.downcase)
  end
end
