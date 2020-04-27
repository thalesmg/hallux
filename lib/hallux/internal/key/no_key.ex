defmodule Hallux.Internal.Key.NoKey do
  defstruct []

  defimpl Hallux.Protocol.Monoid do
    alias Hallux.Internal.Key.Key
    alias Hallux.Internal.Key.NoKey

    def mempty(k = %NoKey{}), do: k

    def mappend(%NoKey{}, k = %Key{}), do: k
    def mappend(%NoKey{}, k = %NoKey{}), do: k
  end
end
