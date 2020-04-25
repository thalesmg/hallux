defmodule Hallux.Internal.Digit.Four do
  @enforce_keys [:a, :b, :c, :d]
  defstruct [:a, :b, :c, :d]

  defimpl Hallux.Protocol.Reduce do
    alias Hallux.Internal.Digit.Four
    alias Hallux.Protocol.Reduce

    def reducer(%Four{a: a, b: b, c: c, d: d}, acc, rfn) do
      Reduce.reducer([a, b, c, d], acc, rfn)
    end

    def reducel(%Four{a: a, b: b, c: c, d: d}, acc, lfn) do
      Reduce.reducel([a, b, c, d], acc, lfn)
    end
  end

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.Digit.Four
    alias Hallux.Protocol.Measured
    alias Hallux.Protocol.Monoid
    alias Hallux.Protocol.Reduce

    def size(four) do
      Reduce.reducel(four, Monoid.mempty(Measured.monoid_type(four)), fn i, acc ->
        Monoid.mappend(i, Measured.size(acc))
      end)
    end

    def monoid_type(_), do: []
  end
end
