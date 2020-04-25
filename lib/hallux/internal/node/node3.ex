defmodule Hallux.Internal.Node.Node3 do
  defstruct [:size, :l, :m, :r]

  defimpl Hallux.Protocol.Reduce do
    alias Hallux.Internal.Node.Node3
    alias Hallux.Protocol.Reduce

    def reducer(%Node3{l: l, m: m, r: r}, acc, rfn) do
      Reduce.reducer([l, m, r], acc, rfn)
    end

    def reducel(%Node3{l: l, m: m, r: r}, acc, lfn) do
      Reduce.reducer([r, m, l], acc, lfn)
    end
  end

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.Node.Node3

    def size(%Node3{size: s}), do: s
    def monoid_type(%Node3{size: s}), do: s
  end
end
