defmodule Hallux.Internal.Interval do
  defstruct [:low, :high, :payload]

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.Interval
    alias Hallux.Internal.Key.Key
    alias Hallux.Internal.MTuple
    alias Hallux.Internal.Prio.Prio
    alias Hallux.Protocol.Monoid

    def size(%Interval{low: low, high: high}) do
      %MTuple{a: %Key{k: low}, b: %Prio{p: high}}
    end

    def monoid_type(%Interval{low: low, high: high}) do
      Monoid.mempty(%MTuple{a: low, b: high})
    end
  end
end
