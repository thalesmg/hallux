defmodule Hallux.Internal.Prio.MInfty do
  defstruct []

  defimpl Hallux.Protocol.Monoid do
    alias Hallux.Internal.Prio.MInfty
    alias Hallux.Internal.Prio.Prio

    def mempty(%MInfty{}), do: %MInfty{}

    def mappend(%MInfty{}, p = %MInfty{}), do: p
    def mappend(%MInfty{}, p = %Prio{}), do: p
  end
end
