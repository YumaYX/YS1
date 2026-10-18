# frozen_string_literal: true

require_relative "helper"

class TestYS1 < Minitest::Test
  def test_version_format
    assert_match(/\A\d+\.\d+\.\d+\z/, YS1::VERSION)
  end

  def test_autoloads_public_modules
    assert_kind_of Module, YS1::IP
    assert_kind_of Module, YS1::Join
    assert_kind_of Module, YS1::CodeBlock
    assert_kind_of Module, YS1::Path
    assert_kind_of Module, YS1::Table
    assert_kind_of Module, YS1::Humanize
    assert_kind_of Module, YS1::Report
    assert_kind_of Module, YS1::Ollama
  end
end
