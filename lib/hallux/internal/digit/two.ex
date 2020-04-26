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

    def size(%Two{a: a, b: b}) do
      Monoid.mappend(
        Measured.size(a),
        Measured.size(b)
      )
    end

    def monoid_type(%Two{a: a}), do: Measured.monoid_type(a)
  end
end
