defmodule Hallux.Internal.Elem do
  defstruct [:e]

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.Size

    def size(_), do: %Size{s: 1}
    def monoid_type(_), do: %Size{}
  end
end
