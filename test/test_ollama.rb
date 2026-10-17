# frozen_string_literal: true

require_relative "helper"

# Offline tests for the Ollama payload builders.
#
# The network-facing calls are exercised by the online tests under
# test/ollama/ (see `rake test:ollama`), which require a running server.
class TestYS1Ollama < Minitest::Test
  def test_generate_body
    body = YS1::Ollama::Request.generate_body(
      "hi",
      model: "gemma4",
      options: { num_ctx: 128 }
    )

    assert_equal "gemma4", body["model"]
    assert_equal false, body["stream"]
    assert_equal "hi", body["prompt"]
    assert_equal({ num_ctx: 128 }, body["options"])
  end

  def test_generate_body_with_extra
    body = YS1::Ollama::Request.generate_body(
      "hi",
      model: "m",
      options: {},
      images: ["QUJD"]
    )

    assert_equal ["QUJD"], body["images"]
  end

  def test_chat_body
    body = YS1::Ollama::Request.chat_body(
      "hi",
      model: "m",
      options: { temperature: 0.4 }
    )

    assert_equal true, body["stream"]
    assert_equal [{ role: "user", content: "hi" }], body["messages"]
    assert_equal({ temperature: 0.4 }, body["options"])
  end

  def test_default_model_constant
    assert_equal "gemma4", YS1::Ollama::DEFAULT_MODEL
  end

  def test_has_no_global_mutable_state
    refute_respond_to YS1::Ollama, :data
  end
end
