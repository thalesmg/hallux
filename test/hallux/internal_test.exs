defmodule Hallux.InternalTest do
  use ExUnit.Case

  alias Hallux
  alias Hallux.Internal
  alias Hallux.{Digits, Views}

  import Hallux.Internal, only: [
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
      assert empty() == Internal.to_tree([])
    end

    test "Single" do
      assert single(:ok) == Internal.to_tree([:ok])
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
      assert expected == Internal.to_tree(1..24)
    end
  end

  describe "to_list/1" do
    test "identity" do
      list = Enum.to_list(1..100)
      assert list == Internal.to_list(Internal.to_tree(list))
    end
  end

  describe "viewL/1" do
    test "Empty tree" do
      assert Views.nilL() == Internal.viewL(empty())
    end

    test "Single tree" do
      assert Views.consL(1, empty()) == Internal.viewL(single(1))
    end

    test "Deep tree" do
      tree = Internal.to_tree(1..24)
      assert %Views.ConsL{
        hd: 1,
        tl: %Internal.Deep{pr: %Digits.One{a: 2}} = tail
      } = Internal.viewL(tree)

      assert %Views.ConsL{
        hd: 2,
        tl: %Internal.Deep{pr: %Digits.Three{a: 3, b: 4, c: 5}} = tail2
      } = Internal.viewL(tail)

      assert %Views.ConsL{
        hd: 3,
        tl: %Internal.Deep{pr: %Digits.Two{a: 4, b: 5}}
      } = Internal.viewL(tail2)
    end
  end

  describe "empty?" do
    test "empty" do
      assert Internal.empty?(empty())
    end

    test "single" do
      refute Internal.empty?(single(1))
    end

    test "deep" do
      refute Internal.empty?(Internal.to_tree(1..10))
    end
  end

  describe "viewR/1" do
    test "Empty tree" do
      assert Views.nilR() == Internal.viewR(empty())
    end

    test "Single tree" do
      assert Views.consR(1, empty()) == Internal.viewR(single(1))
    end

    test "Deep tree" do
      tree = Internal.to_tree(1..24)
      assert %Views.ConsR{
        hd: 24,
        tl: %Internal.Deep{sf: %Digits.Three{a: 21, b: 22, c: 23}} = tail
      } = Internal.viewR(tree)

      assert %Views.ConsR{
        hd: 23,
        tl: %Internal.Deep{sf: %Digits.Two{a: 21, b: 22}} = tail2
      } = Internal.viewR(tail)

      assert %Views.ConsR{
        hd: 22,
        tl: %Internal.Deep{sf: %Digits.One{a: 21}}
      } = Internal.viewR(tail2)
    end
  end

  describe "cons/1" do
    test "Empty" do
      assert single(1) == Internal.cons(empty(), 1)
    end

    test "Single" do
      assert deep(one(2), empty(), one(1)) == Internal.cons(single(1), 2)
    end

    test "Deep : one" do
      tree = deep(one(1), empty(), one(2))
      assert deep(two(3,1), empty(), one(2)) == Internal.cons(tree, 3)
    end

    test "Deep : two" do
      tree = deep(two(1,2), empty(), one(3))
      assert deep(three(4,1,2), empty(), one(3)) == Internal.cons(tree, 4)
    end

    test "Deep : three" do
      tree = deep(three(1,2,3), empty(), one(4))
      assert deep(four(5,1,2,3), empty(), one(4)) == Internal.cons(tree, 5)
    end

    test "Deep : four" do
      tree = deep(four(1,2,3,4), empty(), one(5))
      assert deep(
        two(6,1),
        single(node3(2,3,4)),
        one(5)
      ) == Internal.cons(tree, 6)
    end
  end

  describe "snoc/1" do
    test "Empty" do
      assert single(1) == Internal.snoc(empty(), 1)
    end

    test "Single" do
      assert deep(one(1), empty(), one(2)) == Internal.snoc(single(1), 2)
    end

    test "Deep : one" do
      tree = deep(one(1), empty(), one(2))
      assert deep(one(1), empty(), two(2,3)) == Internal.snoc(tree, 3)
    end

    test "Deep : two" do
      tree = deep(one(1), empty(), two(2,3))
      assert deep(one(1), empty(), three(2,3,4)) == Internal.snoc(tree, 4)
    end

    test "Deep : three" do
      tree = deep(one(1), empty(), three(2,3,4))
      assert deep(one(1), empty(), four(2,3,4,5)) == Internal.snoc(tree, 5)
    end

    test "Deep : four" do
      tree = deep(one(1), empty(), four(2,3,4,5))
      assert deep(
        one(1),
        single(node3(2,3,4)),
        two(5,6)
      ) == Internal.snoc(tree, 6)
    end
  end

  describe "append/2" do
    test "empty empty" do
      assert empty() == Internal.append(empty(), empty())
    end

    test "empty single" do
      assert single(1) == Internal.append(single(1), empty())
      assert single(1) == Internal.append(empty(), single(1))
    end

    test "single single" do
      assert deep(one(1), empty(), one(2)) == Internal.append(single(1), single(2))
    end

    test "single deep" do
      deep = Internal.to_tree(1..10)

      assert deep(
        three(1,2,3),
        deep(one(node3(4,5,6)), empty(), one(node3(7,8,9))),
        two(10, :ok)
      ) == Internal.append(deep, single(:ok))

      assert deep(
        four(:ok,1,2,3),
        deep(one(node3(4,5,6)), empty(), one(node3(7,8,9))),
        one(10)
      ) == Internal.append(single(:ok), deep)
    end

    test "deep deep" do
      deep1 = Internal.to_tree(1..10)
      deep2 = Internal.to_tree(11..20)

      assert deep(
        three(1,2,3),
        deep(
          one(node3(4,5,6)),
          deep(
            one(node2(node3(7,8,9), node2(10,11))),
            empty(),
            one(node2(node2(12,13), node3(14,15,16)))
          ),
          one(node3(17,18,19))
        ),
        one(20)
      ) == Internal.append(deep1, deep2)

      assert deep(
        three(11,12,13),
        deep(
          one(node3(14,15,16)),
          deep(
            one(node2(node3(17,18,19), node2(20,1))),
            empty(),
            one(node2(node2(2,3), node3(4,5,6)))
          ),
          one(node3(7,8,9))
        ),
        one(10)
      ) == Internal.append(deep2, deep1)
    end

    test "different measure" do
      zero = 0
      mfn = fn _ -> 10 end
      rfn = &+/2
      tree1 = Internal.to_tree(1..5, zero, mfn, rfn)
      tree2 = Internal.to_tree(6..10, zero, mfn, rfn)
      appended = Internal.append(tree1, tree2, zero, mfn, rfn)

      assert 100 == Hallux.Measured.size(appended, zero, mfn, rfn)
      assert Enum.to_list(1..10) == Internal.to_list(appended)
    end
  end

end
