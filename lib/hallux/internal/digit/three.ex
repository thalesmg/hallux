defmodule Hallux.Internal.Digit.Three do
  @enforce_keys [:a, :b, :c]
  defstruct [:a, :b, :c]

  defimpl Hallux.Protocol.Reduce do
    alias Hallux.Internal.Digit.Three
    alias Hallux.Protocol.Reduce

    def reducer(%Three{a: a, b: b, c: c}, acc, rfn) do
      Reduce.reducer([a, b, c], acc, rfn)
    end

    def reducel(%Three{a: a, b: b, c: c}, acc, lfn) do
      Reduce.reducer([c, b, a], acc, lfn)
    end
  end

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.Digit.Three
    alias Hallux.Protocol.Measured
    alias Hallux.Protocol.Monoid
    alias Hallux.Protocol.Reduce

    def size(three) do
      Reduce.reducel(three, Monoid.mempty(Measured.monoid_type(three)), fn i, acc ->
        Monoid.mappend(i, Measured.size(acc))
      end)
    end

    def monoid_type(_), do: []
  end
end
