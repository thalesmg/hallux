defmodule Hallux.Internal.FingerTree.Empty do
  defstruct [:monoid]

  defimpl Hallux.Protocol.Reduce do
    alias Hallux.Internal.FingerTree.Empty
    alias Hallux.Protocol.Reduce

    def reducer(%Empty{}, acc, rfn), do: acc
    def reducel(%Empty{}, acc, lfn), do: acc
  end

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.FingerTree.Empty
    alias Hallux.Protocol.Monoid

    def size(%Empty{monoid: m}), do: Monoid.mempty(struct(m))

    def monoid_type(%Empty{monoid: m}), do: struct(m)
  end
end
