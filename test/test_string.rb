# frozen_string_literal: true

require_relative "helper"

class TestYS1String < Minitest::Test
  def test_to_pacs
    pacs = "dummy\nParent0\nchild0\nchild1\nParent1\nchild2\nchild3".to_pacs(/Parent/)

    assert_equal(
      [
        %w[Parent0 child0 child1],
        %w[Parent1 child2 child3]
      ],
      pacs.map(&:family)
    )
  end
end
