defmodule Hallux.Internal.FingerTree.Empty do
  defstruct [:monoid]

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.FingerTree.Empty
    alias Hallux.Protocol.Monoid

    def size(%Empty{monoid: m}), do: Monoid.mempty(struct(m))

    def monoid_type(%Empty{monoid: m}), do: struct(m)
  end
end
