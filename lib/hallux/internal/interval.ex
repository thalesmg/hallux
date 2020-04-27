defmodule Hallux.Internal.Interval do
  defstruct [:low, :high, :payload]

  @type value :: term
  @opaque t(value) :: %__MODULE__{low: integer(), high: integer(), payload: value}
  @type t :: t(term)

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.Interval
    alias Hallux.Internal.IntInterval.IntInterval
    alias Hallux.Internal.IntInterval.NoInterval
    alias Hallux.Protocol.Monoid

    def size(%Interval{low: low, high: high}) do
      %IntInterval{i: {low, high}, v: high}
    end

    def monoid_type(%Interval{}) do
      Monoid.mempty(%NoInterval{})
    end
  end
end
