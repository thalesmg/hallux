defmodule Hallux.Internal.Digit.Two do
  @enforce_keys [:a, :b]
  defstruct [:a, :b]

  defimpl Hallux.Protocol.Reduce do
    alias Hallux.Internal.Digit.Two
    alias Hallux.Protocol.Reduce

    def reducer(%Two{a: a, b: b}, acc, rfn) do
      Reduce.reducer([a, b], acc, rfn)
    end

    def reducel(%Two{a: a, b: b}, acc, lfn) do
      Reduce.reducer([b, a], acc, lfn)
    end
  end

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.Digit.Two
    alias Hallux.Protocol.Measured
    alias Hallux.Protocol.Monoid
    alias Hallux.Protocol.Reduce

    def size(two) do
      Reduce.reducel(two, Monoid.mempty(Measured.monoid_type(two)), fn i, acc ->
        Monoid.mappend(i, Measured.size(acc))
      end)
    end

    def monoid_type(_), do: []
  end
end
