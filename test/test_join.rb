# frozen_string_literal: true

require_relative "helper"

class TestYS1Join < Minitest::Test
  def test_l_join
    users = [{ id: 1, name: "Alice" }, { id: 2, name: "Bob" }, { id: 3, name: "Charlie" }]
    posts = [{ id: 1, user_id: 1, title: "Post 1" }, { id: 2, user_id: 2, title: "Post 2" }]

    expect = [{ id: 1, name: "Alice", user_id: 1, title: "Post 1" },
              { id: 2, name: "Bob", user_id: 2, title: "Post 2" }, { id: 3, name: "Charlie" }]
    assert_equal(expect, YS1::Join.l_join(users, :id, posts, :user_id))

    expect = [{ id: 1, name: "Alice" }, { id: 2, name: "Bob" }, { id: 3, name: "Charlie" }]
    assert_equal(expect, users)
  end

  def test_duplicates_values?
    a = [{ id: 1 }, { id: 2 }]
    assert(!YS1::Join.duplicates_values?(a, :id))

    assert_raises(RuntimeError) do
      a = [{ id: 1 }, { id: 1 }]
      assert(!YS1::Join.duplicates_values?(a, :id))
    end
  end
end
