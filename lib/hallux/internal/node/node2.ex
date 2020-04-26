defmodule Hallux.Internal.Node.Node2 do
  defstruct [:size, :l, :r]

  defimpl Hallux.Protocol.Reduce do
    alias Hallux.Internal.Node.Node2
    alias Hallux.Protocol.Reduce

    def reducer(%Node2{l: l, r: r}, acc, rfn) do
      Reduce.reducer([r, l], acc, rfn)
    end

    def reducel(%Node2{l: l, r: r}, acc, lfn) do
      Reduce.reducer([l, r], acc, lfn)
    end
  end

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.Node.Node2

    def size(%Node2{size: s}), do: s
    def monoid_type(%Node2{size: s}), do: s
  end
end
