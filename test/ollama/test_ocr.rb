# frozen_string_literal: true

require_relative "ollama_helper"

class TestYS1OllamaOCR < Minitest::Test
  def test_ocr
    YS1::Ollama.data.model = TEST_OLLAMA_MODEL
    YS1::Ollama.data.options.think = false

    result = YS1::Ollama::OCR.from_file("#{__dir__}/YS1.png")
    assert_match(/ys1/, result.downcase)
  end
end
