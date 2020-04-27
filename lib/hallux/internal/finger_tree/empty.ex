defmodule Hallux.Internal.FingerTree.Empty do
  defstruct [:monoid]

  defimpl Hallux.Protocol.Reduce do
    alias Hallux.Internal.FingerTree.Empty

    def reducer(%Empty{}, acc, _rfn), do: acc
    def reducel(%Empty{}, acc, _lfn), do: acc
  end

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.FingerTree.Empty
    alias Hallux.Protocol.Monoid

    def size(%Empty{monoid: m}), do: Monoid.mempty(m)

    def monoid_type(%Empty{monoid: m}), do: m
  end
end
