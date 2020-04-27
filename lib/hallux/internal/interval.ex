defmodule Hallux.Internal.Interval do
  defstruct [:low, :high, :payload]

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.Interval
    alias Hallux.Internal.Key.Key
    alias Hallux.Internal.MTuple
    alias Hallux.Internal.Prio.Prio
    alias Hallux.Internal.IntInterval.IntInterval
    alias Hallux.Internal.IntInterval.NoInterval
    alias Hallux.Protocol.Monoid

    # def size(%Interval{low: low, high: high}) do
    #   %MTuple{a: %Key{k: low}, b: %Prio{p: high}}
    # end

    # def monoid_type(%Interval{low: low, high: high}) do
    #   Monoid.mempty(%MTuple{a: low, b: high})
    # end

    def size(%Interval{low: low, high: high}) do
      %IntInterval{i: {low, high}, v: high}
    end

    def monoid_type(%Interval{low: low, high: high}) do
      Monoid.mempty(%NoInterval{})
    end
  end
end
