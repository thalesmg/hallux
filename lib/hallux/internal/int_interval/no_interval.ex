defmodule Hallux.Internal.IntInterval.NoInterval do
  defstruct []

  defimpl Hallux.Protocol.Monoid do
    alias Hallux.Internal.IntInterval
    alias Hallux.Internal.IntInterval.NoInterval

    def mempty(_), do: %NoInterval{}

    def mappend(i1, i2), do: IntInterval.union(i1, i2)
  end
end
