defmodule Hallux.SeqTest do
  use ExUnit.Case

  alias Hallux
  alias Hallux.Seq

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

  describe "new" do
    test "empty" do
      assert %Seq{__tree__: empty()} == Seq.new()
    end

    test "from trees" do
      empty = empty()
      single = single(1)
      deep = Hallux.to_tree(1..50)

      assert %Seq{__tree__: empty} == Seq.new(empty)
      assert %Seq{__tree__: single} == Seq.new(single)
      assert %Seq{__tree__: deep} == Seq.new(deep)
    end

    test "from enum" do
      set = MapSet.new(1..50)
      tree = Hallux.to_tree(set)
      assert %Seq{__tree__: tree} == Seq.new(set)
    end

    test "from enum and transforming" do
      map = Enum.with_index(-50..-1)
      |> Map.new()
      list = Map.values(map)
      tree = Hallux.to_tree(list)
      assert %Seq{__tree__: tree} == Seq.new(map, & elem(&1, 1))
    end
  end

  test "to_list : identity" do
    for size <- 0..100 do
      list = Enum.to_list(0..size)
      assert list == Seq.to_list(Seq.new(list))
    end
  end

  describe "at/1" do
    setup do
      seq = Seq.new(1..100)
      {:ok, seq: seq}
    end

    test "positive indices within bounds", %{seq: seq} do
      for i <- 0..99 do
        assert i + 1 == Seq.at(seq, i)
      end
    end

    test "positive index out of bounds", %{seq: seq} do
      index = Enum.random(100..200)
      refute Seq.at(seq, index)
    end

    test "negative indices within bounds", %{seq: seq} do
      for i <- -1..-100 do
        assert 100 + i + 1 == Seq.at(seq, i)
      end
    end

    test "negative index out of bounds", %{seq: seq} do
      index = Enum.random(-101..-200)
      refute Seq.at(seq, index)
    end
  end

  describe "split_at/1" do
    setup do
      seq = Seq.new(1..100)
      {:ok, seq: seq}
    end

    test "positive indices within bounds", %{seq: seq} do
      assert {:ok, {left, right}} = Seq.split_at(seq, 0)
      expected_left = []
      expected_right = Enum.to_list(1..100)
      assert expected_left == Seq.to_list(left)
      assert expected_right == Seq.to_list(right)
      for i <- 1..99 do
        assert {:ok, {left, right}} = Seq.split_at(seq, i)
        expected_left = Enum.to_list(1..i)
        expected_right = (i + 1)..100 |> Enum.to_list()
        assert expected_left == Seq.to_list(left)
        assert expected_right == Seq.to_list(right)
      end
    end

    test "positive index out of bounds", %{seq: seq} do
      index = Enum.random(100..200)
      assert :error == Seq.split_at(seq, index)
    end

    test "negative indices within bounds", %{seq: seq} do
      for i <- -1..-99 do
        assert {:ok, {left, right}} = Seq.split_at(seq, i)
        expected_left = Enum.to_list(1..100 + i)
        expected_right = (100 + i + 1)..100 |> Enum.to_list()
        assert expected_left == Seq.to_list(left)
        assert expected_right == Seq.to_list(right)
      end
      assert {:ok, {left, right}} = Seq.split_at(seq, -100)
      expected_left = []
      expected_right = 1..100 |> Enum.to_list()
      assert expected_left == Seq.to_list(left)
      assert expected_right == Seq.to_list(right)
    end

    test "negative index out of bounds", %{seq: seq} do
      index = Enum.random(-101..-200)
      assert :error == Seq.split_at(seq, index)
    end
  end

  test "size/1 counts the number of elements" do
    assert 0 == Seq.size(Seq.new())
    for size <- 1..100 do
      seq = Seq.new(0..size - 1)
      assert size == Seq.size(seq)
    end
  end

  test "empty?/1" do
    assert Seq.empty?(Seq.new())
    for size <- 1..100 do
      refute Seq.empty?(Seq.new(0..size)),
        "Seq should not be empty with 0..#{size}"
    end
  end

  test "cons/1" do
    Enum.reduce(1..100, Seq.new(), fn num, seq ->
      expected = Seq.new(num..1)
      consed = Seq.cons(seq, num)
      assert expected == consed
      consed
    end)
  end

  test "snoc/1" do
    Enum.reduce(1..100, Seq.new(), fn num, seq ->
      expected = Enum.to_list(1..num)
      snoced = Seq.snoc(seq, num)
      assert expected == snoced |> Seq.to_list()
      snoced
    end)
  end

  describe "append" do
    test "empty empty" do
      assert Seq.new() == Seq.append(Seq.new(), Seq.new())
    end

    test "empty single" do
      assert Seq.new([1]) == Seq.append(Seq.new([1]), Seq.new())
      assert Seq.new([1]) == Seq.append(Seq.new(), Seq.new([1]))
    end

    test "empty deep" do
      assert Seq.new(1..10) == Seq.append(Seq.new(1..10), Seq.new())
      assert Seq.new(1..10) == Seq.append(Seq.new(), Seq.new(1..10))
    end

    test "single deep" do
      assert Enum.to_list(1..10) == Seq.append(Seq.new([1]), Seq.new(2..10))
      |> Seq.to_list()
      assert Enum.to_list(1..10) == Seq.append(Seq.new(1..9), Seq.new([10]))
      |> Seq.to_list()
    end

    test "deep deep" do
      assert Enum.to_list(1..20) == Seq.append(Seq.new(1..10), Seq.new(11..20))
      |> Seq.to_list()
    end
  end

end
