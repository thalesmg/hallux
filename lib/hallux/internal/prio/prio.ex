defmodule Hallux.Internal.Prio.Prio do
  defstruct [:p]

  defimpl Hallux.Protocol.Monoid do
    alias Hallux.Internal.Prio.MInfty
    alias Hallux.Internal.Prio.Prio

    def mempty(%Prio{}), do: %MInfty{}

    def mappend(p = %Prio{}, %MInfty{}), do: p
    def mappend(%Prio{p: p1}, %Prio{p: p2}), do: %Prio{p: max(p1, p2)}
  end
end
