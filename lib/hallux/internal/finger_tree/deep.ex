defmodule Hallux.Internal.FingerTree.Deep do
  defstruct [:monoid, :size, :l, :m, :r]

  defimpl Hallux.Protocol.Reduce do
    alias Hallux.Internal.FingerTree.Deep
    alias Hallux.Protocol.Reduce

    def reducer(%Deep{l: pr, m: m, r: sf}, acc, rfn) do
      Reduce.reducer(
        pr,
        Reduce.reducer(
          m,
          Reduce.reducer(
            sf,
            acc,
            rfn
          ),
          &Reduce.reducer(&1, &2, rfn)
        ),
        rfn
      )
    end

    def reducel(%Deep{l: pr, m: m, r: sf}, acc, lfn) do
      Reduce.reducel(
        sf,
        Reduce.reducel(
          m,
          Reduce.reducel(
            pr,
            acc,
            lfn
          ),
          &Reduce.reducel(&1, &2, lfn)
        ),
        lfn
      )
    end
  end

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.FingerTree.Deep

    def size(%Deep{size: size}), do: size

    def monoid_type(%Deep{monoid: m}), do: struct(m)
  end
end
