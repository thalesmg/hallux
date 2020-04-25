defmodule Hallux.Internal.Node.Node2 do
  defstruct [:size, :l, :r]

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.Node.Node2

    def size(%Node2{size: s}), do: s
    def monoid_type(%Node2{size: s}), do: s
  end
end
