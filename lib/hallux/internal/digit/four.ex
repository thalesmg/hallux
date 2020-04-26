defmodule Hallux.Internal.Digit.Four do
  @enforce_keys [:a, :b, :c, :d]
  defstruct [:a, :b, :c, :d]

  defimpl Hallux.Protocol.Reduce do
    alias Hallux.Internal.Digit.Four
    alias Hallux.Protocol.Reduce

    def reducer(%Four{a: a, b: b, c: c, d: d}, acc, rfn) do
      Reduce.reducer([d, c, b, a], acc, rfn)
    end

    def reducel(%Four{a: a, b: b, c: c, d: d}, acc, lfn) do
      Reduce.reducer([a, b, c, d], acc, lfn)
    end
  end

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.Digit.Four
    alias Hallux.Protocol.Measured
    alias Hallux.Protocol.Monoid
    alias Hallux.Protocol.Reduce

    def size(%Four{a: a, b: b, c: c, d: d}) do
      Monoid.mappend(
        Measured.size(a),
        Monoid.mappend(
          Measured.size(b),
          Monoid.mappend(
            Measured.size(c),
            Measured.size(d)
          )
        )
      )
    end

    def monoid_type(%Four{a: a}), do: Measured.monoid_type(a)
  end
end
