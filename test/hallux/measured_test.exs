defmodule Hallux.MeasuredTest do
  use ExUnit.Case

  alias Hallux.Measured
  alias Hallux.Digits.{One, Two, Three, Four}
  alias Hallux.{Node2, Node3}
  alias Hallux.{Empty, Single, Deep}

  import Hallux, only: [
    empty: 0,
    single: 1,
    deep: 3,
    one: 1,
    two: 2,
    three: 3,
    four: 4,
    node2: 2,
    node2: 5,
    node3: 3,
    node3: 6
  ]

  describe "Nodes" do
    setup do
      measure_fn = fn _ -> 1 end
      reduce_fn = &+/2
      zero = 0

      {:ok, %{mfn: measure_fn, rfn: reduce_fn, z: zero}}
    end

    test "counting measure : node2 constructor", %{mfn: mfn, rfn: rfn, z: z} do
      assert 2 == Measured.size(node2(10, 20), z, mfn, rfn)
    end

    test "counting measure : node3 constructor", %{mfn: mfn, rfn: rfn, z: z} do
      assert 3 == Measured.size(node3(10, 20, 30), z, mfn, rfn)
    end

    test "counting measure : node2 cached", %{mfn: mfn, rfn: rfn, z: z} do
      assert 99 == Measured.size(%Node2{l: 10, r: 20, __size__: 99}, z, mfn, rfn)
    end

    test "counting measure : node3 cached", %{mfn: mfn, rfn: rfn, z: z} do
      assert 999 == Measured.size(%Node3{l: 10, m: 30, r: 20, __size__: 999}, z, mfn, rfn)
    end
  end

  describe "Digits" do
    setup do
      measure_fn = fn _ -> 1 end
      reduce_fn = &+/2
      zero = 0

      {:ok, %{mfn: measure_fn, rfn: reduce_fn, z: zero}}
    end

    test "counting measure : one", %{mfn: mfn, rfn: rfn, z: z} do
      assert 1 == Measured.size(%One{a: 50}, z, mfn, rfn)
    end

    test "counting measure : two", %{mfn: mfn, rfn: rfn, z: z} do
      assert 2 == Measured.size(%Two{a: 50, b: 40}, z, mfn, rfn)
    end

    test "counting measure : three", %{mfn: mfn, rfn: rfn, z: z} do
      assert 3 == Measured.size(%Three{a: 50, b: 40, c: 60}, z, mfn, rfn)
    end

    test "counting measure : four", %{mfn: mfn, rfn: rfn, z: z} do
      assert 4 == Measured.size(%Four{a: 50, b: 40, c: 60, d: -10}, z, mfn, rfn)
    end
  end

  describe "Trees" do
    setup do
      measure_fn = fn _ -> 1 end
      reduce_fn = &+/2
      zero = 0

      {:ok, %{mfn: measure_fn, rfn: reduce_fn, z: zero}}
    end

    test "counting measure : empty", %{mfn: mfn, rfn: rfn, z: z} do
      assert 0 == Measured.size(%Empty{}, z, mfn, rfn)
    end

    test "counting measure : single", %{mfn: mfn, rfn: rfn, z: z} do
      assert 1 == Measured.size(%Single{v: 100}, z, mfn, rfn)
    end

    test "counting measure : deep (cached)", %{mfn: mfn, rfn: rfn, z: z} do
      assert 99 == Measured.size(%Deep{__size__: 99}, z, mfn, rfn)
    end

    test "counting measure : deep constructor", %{mfn: mfn, rfn: rfn, z: z} do
      n1 = node2(10, 20, z, mfn, rfn)
      n2 = node3(50, 50, 60, z, mfn, rfn)
      # Digits are calculated on the fly.
      pr = three(1,2,3)
      sf = four(-1,-2,-3,-4)
      assert 12 == Measured.size(
        deep(
          pr,
          deep(n1, empty(), n2),
          sf
        ),
        z,
        mfn,
        rfn
      )
    end
  end

end
