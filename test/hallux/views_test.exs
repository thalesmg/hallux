defmodule Hallux.ViewsTest do
  use ExUnit.Case

  alias Hallux
  alias Hallux.Internal

  import Hallux.Views,
    only: [
      nilL: 0,
      nilR: 0
    ]

  describe "Enumerable Left" do
    test "count : nil" do
      assert 0 == Enum.count(nilL())
    end

    test "count : cons" do
      tree = Internal.to_tree(1..10)
      assert 10 == Enum.count(Internal.viewL(tree))
    end

    test "member? : nil" do
      assert false == Enum.member?(nilL(), 1)
    end

    test "member? : cons" do
      tree = Internal.to_tree(1..10)
      target = Enum.random(1..10)

      assert true == Enum.member?(Internal.viewL(tree), target),
             "#{inspect(target)} should be a member"
    end

    test "member? : last cons" do
      tree = Internal.to_tree(1..10)
      assert true == Enum.member?(Internal.viewL(tree), 10), "10 should be a member"
    end

    test "reduce : nil" do
      assert_raise Enum.EmptyError, fn ->
        Enum.reduce(nilL(), &(&1 + 1))
      end
    end

    test "reduce : cons" do
      tree = Internal.to_tree(1..10)
      list = Enum.to_list(1..10)
      assert list == Enum.to_list(Internal.viewL(tree))
    end
  end

  describe "Enumerable Right" do
    test "count : nil" do
      assert 0 == Enum.count(nilR())
    end

    test "count : cons" do
      tree = Internal.to_tree(1..10)
      assert 10 == Enum.count(Internal.viewR(tree))
    end

    test "member? : nil" do
      assert false == Enum.member?(nilR(), 1)
    end

    test "member? : cons" do
      tree = Internal.to_tree(1..10)
      target = Enum.random(1..10)

      assert true == Enum.member?(Internal.viewR(tree), target),
             "#{inspect(target)} should be a member"
    end

    test "member? : last cons" do
      tree = Internal.to_tree(1..10)
      assert true == Enum.member?(Internal.viewR(tree), 1), "1 should be a member"
    end

    test "reduce : nil" do
      assert_raise Enum.EmptyError, fn ->
        Enum.reduce(nilR(), &(&1 + 1))
      end
    end

    test "reduce : cons" do
      tree = Internal.to_tree(1..10)
      list = Enum.to_list(10..1)
      assert list == Enum.to_list(Internal.viewR(tree))
    end
  end
end
