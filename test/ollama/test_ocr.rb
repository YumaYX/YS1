# frozen_string_literal: true

require_relative "ollama_helper"

class TestYS1OllamaOCR < Minitest::Test
  def test_ocr
    result = YS1::Ollama::OCR.from_file(
      "#{__dir__}/YS1.png",
      model: TEST_OLLAMA_MODEL,
      options: { think: false }
    )
    assert_match(/ys1/, result.downcase)
  end
end
