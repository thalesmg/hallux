defmodule Hallux.Internal.Key.Key do
  defstruct [:k]

  defimpl Hallux.Protocol.Monoid do
    alias Hallux.Internal.Key.Key
    alias Hallux.Internal.Key.NoKey

    def mempty(%Key{}), do: %NoKey{}

    def mappend(%Key{}, k = %Key{}), do: k
    def mappend(k = %Key{}, %NoKey{}), do: k
  end
end
