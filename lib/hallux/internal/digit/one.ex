defmodule Hallux.Internal.Digit.One do
  @enforce_keys [:a]
  defstruct [:a]

  defimpl Hallux.Protocol.Reduce do
    alias Hallux.Internal.Digit.One
    alias Hallux.Protocol.Reduce

    def reducer(%One{a: a}, acc, rfn) do
      Reduce.reducer([a], acc, rfn)
    end

    def reducel(%One{a: a}, acc, lfn) do
      Reduce.reducer([a], acc, lfn)
    end
  end

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.Digit.One
    alias Hallux.Protocol.Measured

    def size(%One{a: a}) do
      Measured.size(a)
    end

    def monoid_type(%One{a: a}), do: Measured.monoid_type(a)
  end
end
