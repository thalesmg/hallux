defmodule HalluxTest do
  use ExUnit.Case

  alias Hallux
  alias Hallux.{Digits, Node2, Node3, Views}

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

  describe "to_list/1" do
    test "identity" do
      list = Enum.to_list(1..100)
      assert list == Hallux.to_list(Hallux.to_tree(list))
    end
  end

  describe "viewL/1" do
    test "Empty tree" do
      assert Views.nilL() == Hallux.viewL(empty())
    end

    test "Single tree" do
      assert Views.consL(1, empty()) == Hallux.viewL(single(1))
    end

    test "Deep tree" do
      tree = Hallux.to_tree(1..24)
      assert %Views.ConsL{
        hd: 1,
        tl: %Hallux.Deep{pr: %Digits.One{a: 2}} = tail
      } = Hallux.viewL(tree)

      assert %Views.ConsL{
        hd: 2,
        tl: %Hallux.Deep{pr: %Digits.Three{a: 3, b: 4, c: 5}} = tail2
      } = Hallux.viewL(tail)

      assert %Views.ConsL{
        hd: 3,
        tl: %Hallux.Deep{pr: %Digits.Two{a: 4, b: 5}}
      } = Hallux.viewL(tail2)
    end
  end

  describe "empty?" do
    test "empty" do
      assert Hallux.empty?(empty())
    end

    test "single" do
      refute Hallux.empty?(single(1))
    end

    test "deep" do
      refute Hallux.empty?(Hallux.to_tree(1..10))
    end
  end

  describe "viewR/1" do
    test "Empty tree" do
      assert Views.nilR() == Hallux.viewR(empty())
    end

    test "Single tree" do
      assert Views.consR(1, empty()) == Hallux.viewR(single(1))
    end

    test "Deep tree" do
      tree = Hallux.to_tree(1..24)
      assert %Views.ConsR{
        hd: 24,
        tl: %Hallux.Deep{sf: %Digits.Three{a: 21, b: 22, c: 23}} = tail
      } = Hallux.viewR(tree)

      assert %Views.ConsR{
        hd: 23,
        tl: %Hallux.Deep{sf: %Digits.Two{a: 21, b: 22}} = tail2
      } = Hallux.viewR(tail)

      assert %Views.ConsR{
        hd: 22,
        tl: %Hallux.Deep{sf: %Digits.One{a: 21}}
      } = Hallux.viewR(tail2)
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

  describe "append/2" do
    test "empty empty" do
      assert empty() == Hallux.append(empty(), empty())
    end

    test "empty single" do
      assert single(1) == Hallux.append(single(1), empty())
      assert single(1) == Hallux.append(empty(), single(1))
    end

    test "single single" do
      assert deep(one(1), empty(), one(2)) == Hallux.append(single(1), single(2))
    end

    test "single deep" do
      deep = Hallux.to_tree(1..10)

      assert deep(
        three(1,2,3),
        deep(one(node3(4,5,6)), empty(), one(node3(7,8,9))),
        two(10, :ok)
      ) == Hallux.append(deep, single(:ok))

      assert deep(
        four(:ok,1,2,3),
        deep(one(node3(4,5,6)), empty(), one(node3(7,8,9))),
        one(10)
      ) == Hallux.append(single(:ok), deep)
    end

    test "deep deep" do
      deep1 = Hallux.to_tree(1..10)
      deep2 = Hallux.to_tree(11..20)

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
      ) == Hallux.append(deep1, deep2)

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
      ) == Hallux.append(deep2, deep1)
    end
  end

end
