defmodule Hallux.ViewsTest do
  use ExUnit.Case

  alias Hallux
  alias Hallux.Views
  import Hallux.Views, only: [
    nilL: 0,
    nilR: 0
  ]

  describe "Enumerable Left" do
    test "count : nil" do
      assert 0 == Enum.count(nilL())
    end

    test "count : cons" do
      tree = Hallux.to_tree(1..10)
      assert 10 == Enum.count(Hallux.viewL(tree))
    end

    test "member? : nil" do
      assert false == Enum.member?(nilL(), 1)
    end

    test "member? : cons" do
      tree = Hallux.to_tree(1..10)
      target = Enum.random(1..10)
      assert true == Enum.member?(Hallux.viewL(tree), target),
        "#{inspect target} should be a member"
    end

    test "member? : last cons" do
      tree = Hallux.to_tree(1..10)
      assert true == Enum.member?(Hallux.viewL(tree), 10),
        "10 should be a member"
    end

    test "reduce : nil" do
      assert_raise Enum.EmptyError, fn ->
        Enum.reduce(nilL(), & &1 + 1)
      end
    end

    test "reduce : cons" do
      tree = Hallux.to_tree(1..10)
      list = Enum.to_list(1..10)
      assert list == Enum.to_list(Hallux.viewL(tree))
    end
  end

  describe "Enumerable Right" do
    test "count : nil" do
      assert 0 == Enum.count(nilR())
    end

    test "count : cons" do
      tree = Hallux.to_tree(1..10)
      assert 10 == Enum.count(Hallux.viewR(tree))
    end

    test "member? : nil" do
      assert false == Enum.member?(nilR(), 1)
    end

    test "member? : cons" do
      tree = Hallux.to_tree(1..10)
      target = Enum.random(1..10)
      assert true == Enum.member?(Hallux.viewR(tree), target),
        "#{inspect target} should be a member"
    end

    test "member? : last cons" do
      tree = Hallux.to_tree(1..10)
      assert true == Enum.member?(Hallux.viewR(tree), 1),
        "1 should be a member"
    end

    test "reduce : nil" do
      assert_raise Enum.EmptyError, fn ->
        Enum.reduce(nilR(), & &1 + 1)
      end
    end

    test "reduce : cons" do
      tree = Hallux.to_tree(1..10)
      list = Enum.to_list(10..1)
      assert list == Enum.to_list(Hallux.viewR(tree))
    end
  end
end
