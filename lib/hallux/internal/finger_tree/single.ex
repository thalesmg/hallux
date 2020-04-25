defmodule Hallux.Internal.FingerTree.Single do
  defstruct [:monoid, :x]

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.FingerTree.Single
    alias Hallux.Protocol.Monoid

    def size(%Single{x: x}), do: Measured.size(x)

    def monoid_type(%Single{monoid: m}), do: struct(m)
  end
end
