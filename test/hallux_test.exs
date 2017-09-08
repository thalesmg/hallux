defmodule HalluxTest do
  use ExUnit.Case

  alias Hallux
  alias Hallux.{Digits, Views}

  import Hallux, only: [
    empty: 0,
    single: 1,
    deep: 3,
    one: 1,
    two: 2,
    three: 3,
    four: 4,
    node2: 2,
    node3: 3
  ]

  describe "to_tree/1" do
    test "Empty" do
      assert empty() == Hallux.to_tree([])
    end

    test "Single" do
      assert single(:ok) == Hallux.to_tree([:ok])
    end

    test "Deep" do
      expected =
        deep(
          two(1, 2),
          deep(
            three(node3(3,4,5), node3(6,7,8), node3(9,10,11)),
            single(node3(node3(12,13,14), node3(15,16,17), node3(18,19,20))),
            one(node3(21,22,23))
          ),
          one(24)
        )
      assert expected == Hallux.to_tree(1..24)
    end
  end

  describe "viewL/1" do
    test "Empty tree" do
      assert Views.nilL() == Hallux.viewL(empty())
    end

    test "Single tree" do
      assert Views.consL(1, Views.nilL) == Hallux.viewL(single(1))
    end

    test "Deep tree" do
      tree = Hallux.to_tree(1..24)
      assert %Views.ConsL{
        hd: 1,
        tl: %Hallux.Deep{pr: %Digits.One{a: 2}}
      } = Hallux.viewL(tree)
    end
  end

  describe "cons/1" do
    test "Empty" do
      assert single(1) == Hallux.cons(empty(), 1)
    end

    test "Single" do
      assert deep(one(2), empty(), one(1)) == Hallux.cons(single(1), 2)
    end

    test "Deep : one" do
      tree = deep(one(1), empty(), one(2))
      assert deep(two(3,1), empty(), one(2)) == Hallux.cons(tree, 3)
    end

    test "Deep : two" do
      tree = deep(two(1,2), empty(), one(3))
      assert deep(three(4,1,2), empty(), one(3)) == Hallux.cons(tree, 4)
    end

    test "Deep : three" do
      tree = deep(three(1,2,3), empty(), one(4))
      assert deep(four(5,1,2,3), empty(), one(4)) == Hallux.cons(tree, 5)
    end

    test "Deep : four" do
      tree = deep(four(1,2,3,4), empty(), one(5))
      assert deep(
        two(6,1),
        single(node3(2,3,4)),
        one(5)
      ) == Hallux.cons(tree, 6)
    end
  end

  describe "snoc/1" do
    test "Empty" do
      assert single(1) == Hallux.snoc(empty(), 1)
    end

    test "Single" do
      assert deep(one(1), empty(), one(2)) == Hallux.snoc(single(1), 2)
    end

    test "Deep : one" do
      tree = deep(one(1), empty(), one(2))
      assert deep(one(1), empty(), two(2,3)) == Hallux.snoc(tree, 3)
    end

    test "Deep : two" do
      tree = deep(one(1), empty(), two(2,3))
      assert deep(one(1), empty(), three(2,3,4)) == Hallux.snoc(tree, 4)
    end

    test "Deep : three" do
      tree = deep(one(1), empty(), three(2,3,4))
      assert deep(one(1), empty(), four(2,3,4,5)) == Hallux.snoc(tree, 5)
    end

    test "Deep : four" do
      tree = deep(one(1), empty(), four(2,3,4,5))
      assert deep(
        one(1),
        single(node3(2,3,4)),
        two(5,6)
      ) == Hallux.snoc(tree, 6)
    end
  end

end
