defmodule Hallux.Internal.Node.Node3 do
  defstruct [:size, :l, :m, :r]

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.Node.Node3

    def size(%Node3{size: s}), do: s
    def monoid_type(%Node3{size: s}), do: s
  end
end
