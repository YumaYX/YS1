# frozen_string_literal: true

require_relative "ollama_helper"

class TestYS1OllamaExtract < Minitest::Test
  def test_prompt
    prompt = YS1::Ollama::Extract.prompt_template("name, age", "Taro is 20")
    assert_match(/name, age/, prompt)
    assert_match(/Taro is 20/, prompt)
  end

  def test_from_text
    result = YS1::Ollama::Extract.from_text(
      %({"name": string, "age": number}),
      "Taro is 20 years old.",
      model: TEST_OLLAMA_MODEL,
      options: { num_ctx: 512, think: false }
    )
    assert_equal("Taro", result["name"])
    assert_equal(20, result["age"])
  end
end
