defmodule Hallux.Internal.FingerTree.Deep do
  defstruct [:monoid, :size, :l, :m, :r]

  defimpl Hallux.Protocol.Reduce do
    alias Hallux.Internal.FingerTree.Deep
    alias Hallux.Protocol.Reduce

    def reducer(%Deep{l: pr, m: m, r: sf}, acc, rfn) do
      redr = &Reduce.reducer/3



      Reduce.reducer(
        pr,
        Reduce.reducer(
          m,
          Reduce.reducer(),

        ),
        rfn)
    end
    def reducel(%Deep{x: x}, acc, lfn), do: lfn.(x, acc)
  end

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.FingerTree.Deep
    alias Hallux.Protocol.Monoid

    def size(%Deep{size: size}), do: size

    def monoid_type(%Deep{monoid: m}), do: struct(m)
  end
end
