defmodule Hallux.SplitTest do
  use ExUnit.Case

  alias Hallux.Measured
  alias Hallux.Split

  import Hallux, only: [
    empty: 0,
    single: 1,
    deep: 3,
    deep: 6,
    one: 1,
    two: 2,
    three: 3,
    four: 4,
    node3: 3,
    node3: 6
  ]

  defp split(l, x, r) do
    %Split{l: l, x: x, r: r}
  end

  describe "split" do
    setup do
      p = & &1 >= 51
      mfn = fn _ -> 1 end
      rfn = &+/2
      z = 0

      {:ok, p: p, mfn: mfn, rfn: rfn, z: z}
    end

    test "Split at point", %{p: p, mfn: mfn, rfn: rfn, z: z} do
      tree = Hallux.to_tree(1..100)

      {left, right} = Split.split(tree, p, z, mfn, rfn)

      assert 50 == Measured.size(left, z, mfn, rfn)
      assert 50 == Measured.size(right, z, mfn, rfn)

      assert 1 == Hallux.headL(left)
      assert 50 == Hallux.headR(left)

      assert 51 == Hallux.headL(right)
      assert 100 == Hallux.headR(right)
    end
  end

  describe "split_tree" do
    setup do
      p = & &1 > 10
      mfn = & &1
      rfn = fn x, _ -> x end
      z = 0

      {:ok, p: p, mfn: mfn, rfn: rfn, z: z}
    end

    test "empty", %{p: p, mfn: mfn, rfn: rfn, z: z} do
      assert_raise FunctionClauseError, fn ->
        Split.split_tree(
          p, z, empty(), z, mfn, rfn
        )
      end
    end

    test "single", %{p: p, mfn: mfn, rfn: rfn, z: z} do
      assert split(empty(), 4, empty()) == Split.split_tree(
        p, z, single(4), z, mfn, rfn
      )
    end

    test "deep", %{p: p, mfn: mfn, rfn: rfn, z: z} do
      tree = Hallux.to_tree(6..16, z, mfn, rfn)
      assert split(
        deep(
          four(6,7,8,9),
          empty(),
          one(10),
          z, mfn, rfn
        ),
        11,
        deep(
          one(12),
          single(node3(13,14,15, z, mfn, rfn)),
          one(16),
          z, mfn, rfn
        )
      ) == Split.split_tree(
        p, z, tree, z, mfn, rfn
      )
    end
  end

  describe "split_tree : random access" do
    setup do
      p = & &1 >= 17
      mfn = fn _ -> 1 end
      rfn = &+/2
      z = 0

      {:ok, p: p, mfn: mfn, rfn: rfn, z: z}
    end

    test "random access", %{p: p, mfn: mfn, rfn: rfn, z: z} do
      tree = Hallux.to_tree(1..22, z, mfn, rfn)

      assert split(
        deep(
          three(1,2,3),
          deep(
            two(node3(4,5,6), node3(7,8,9)),
            empty(),
            two(node3(10,11,12), node3(13,14,15))
          ),
          one(16)
        ),
        17,
        deep(
          one(18),
          single(node3(19,20,21)),
          one(22)
        )
      ) == Split.split_tree(p, z, tree, z, mfn, rfn)
    end

    test "more random access", %{mfn: mfn, rfn: rfn, z: z} do
      tree = Hallux.to_tree(1..100, z, mfn, rfn)

      for x <- 1..100 do
        p = & &1 >= x
        assert %Split{x: ^x} = Split.split_tree(p, z, tree, z, mfn, rfn)
      end
    end
  end

  describe "split_digit" do
    setup do
      p = & &1 > 10
      mfn = & &1
      rfn = fn x, _ -> x end

      {:ok, p: p, mfn: mfn, rfn: rfn}
    end

    test "one", %{p: p, mfn: mfn, rfn: rfn} do
      assert split([], 1, []) == Split.split_digit(p, 0, one(1), 0, mfn, rfn)
    end

    test "two", %{p: p, mfn: mfn, rfn: rfn} do
      assert split([8], 9, []) == Split.split_digit(p, 0, two(8,9), 0, mfn, rfn)
      assert split([9], 10, []) == Split.split_digit(p, 0, two(9,10), 0, mfn, rfn)
      assert split([10], 11, []) == Split.split_digit(p, 0, two(10,11), 0, mfn, rfn)
      assert split([], 11, [12]) == Split.split_digit(p, 0, two(11,12), 0, mfn, rfn)
    end

    test "three", %{p: p, mfn: mfn, rfn: rfn} do
      assert split([8,9], 10, []) == Split.split_digit(p, 0, three(8,9,10), 0, mfn, rfn)
      assert split([9,10], 11, []) == Split.split_digit(p, 0, three(9,10,11), 0, mfn, rfn)
      assert split([10], 11, [12]) == Split.split_digit(p, 0, three(10,11,12), 0, mfn, rfn)
      assert split([], 11, [12,13]) == Split.split_digit(p, 0, three(11,12,13), 0, mfn, rfn)
    end

    test "four", %{p: p, mfn: mfn, rfn: rfn} do
      assert split([7,8,9], 10, []) == Split.split_digit(p, 0, four(7,8,9,10), 0, mfn, rfn)
      assert split([8,9,10], 11, []) == Split.split_digit(p, 0, four(8,9,10,11), 0, mfn, rfn)
      assert split([9,10], 11, [12]) == Split.split_digit(p, 0, four(9,10,11,12), 0, mfn, rfn)
      assert split([10], 11, [12,13]) == Split.split_digit(p, 0, four(10,11,12,13), 0, mfn, rfn)
      assert split([], 11, [12,13,14]) == Split.split_digit(p, 0, four(11,12,13,14), 0, mfn, rfn)
    end
  end
end
