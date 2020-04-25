defmodule Hallux.Internal.Node.Node2 do
  defstruct [:size, :l, :r]

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.Node.Node2

    def size(%Node2{size: s}, _, _, _), do: s
  end
end
