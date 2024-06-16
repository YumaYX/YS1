# frozen_string_literal: true

require_relative "helper"

class TestYS1Cmd < Minitest::Test
  def test_usage
    assert_raises(SystemExit) do
      assert_output("Usage:\n  command args\n") { YS1::Cmd.usage("/path/to/command", "args") }
    end
  end
end
