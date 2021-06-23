defmodule Hallux.Internal.OrderedHashBounds.Value do
  defstruct [:value, :ordered_hash_bounds]

  alias Hallux.Internal.OrderedHashBounds

  def new(key, value) do
    ordered_hash_bounds = OrderedHashBounds.new(key, value)

    %__MODULE__{
      value: value,
      ordered_hash_bounds: ordered_hash_bounds
    }
  end

  defimpl Hallux.Protocol.Measured do
    alias Hallux.Internal.OrderedHashBounds.Value
    alias Hallux.Internal.OrderedHashBounds

    def monoid_type(%Value{}) do
      OrderedHashBounds.new()
    end

    def size(%Value{ordered_hash_bounds: ordered_hash_bounds}) do
      ordered_hash_bounds
    end
  end
end
