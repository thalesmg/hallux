defmodule Hallux.Internal.FingerTree.Single do
  defstruct [:monoid, :x]

  defimpl Hallux.Protocol.Reduce do
    alias Hallux.Internal.FingerTree.Single

    def reducer(%Single{x: x}, acc, rfn), do: rfn.(x, acc)
    def reducel(%Single{x: x}, acc, lfn), do: lfn.(x, acc)
  end

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.FingerTree.Single
    alias Hallux.Protocol.Measured

    def size(%Single{x: x}), do: Measured.size(x)

    def monoid_type(%Single{monoid: m}), do: struct(m)
  end
end
