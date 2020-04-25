defmodule Hallux.Internal.FingerTree.Deep do
  defstruct [:monoid, :size, :l, :m, :r]

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.FingerTree.Deep
    alias Hallux.Protocol.Monoid

    def size(%Deep{size: size}), do: size

    def monoid_type(%Deep{monoid: m}), do: struct(m)
  end
end
