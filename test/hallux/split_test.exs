defmodule Hallux.SplitTest do
  use ExUnit.Case

  alias Hallux.Split

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

  defp split(l, x, r) do
    %Split{l: l, x: x, r: r}
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
