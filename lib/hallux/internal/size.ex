defmodule Hallux.Internal.Size do
  defstruct [:s]

  defimpl Hallux.Protocol.Monoid do
    alias Hallux.Internal.Size

    def mappend(%Size{s: s1}, %Size{s: s2}), do: %Size{s: s1 + s2}
    def mempty(_), do: %Size{s: 0}
  end
end
