defmodule Hallux.Internal.OrderedHashBounds do
  defstruct [:order, :min, :max]

  alias Hallux.Internal.OrderedHashBounds.MinOrder
  alias Hallux.Internal.OrderedHashBounds.Order

  def hash(value) do
    :crypto.hash(:sha, :erlang.term_to_binary(value))
  end

  def new() do
    %__MODULE__{
      order: %MinOrder{},
      # Yes, reversed
      min: max_hash(),
      max: min_hash()
    }
  end

  def new(order, value) do
    hash = hash(value)

    %__MODULE__{
      order: %Order{order: order},
      min: hash,
      max: hash
    }
  end

  def min_hash() do
    <<0::size(160)>>
  end

  def max_hash() do
    <<0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF::size(160)>>
  end

  def compare_order(order: %MinOrder{}, order: %MinOrder{}) do
    :eq
  end

  def compare_order(%MinOrder{}, _) do
    :lt
  end

  def compare_order(_, %MinOrder{}) do
    :gt
  end

  def compare_order(%Order{order: order1}, %Order{order: order2}) do
    compare(order1, order2)
  end

  def compare_hash_min(%__MODULE__{min: min1}, %__MODULE__{min: min2}) do
    compare(min1, min2)
  end

  def compare_hash_max(%__MODULE__{max: max1}, %__MODULE__{max: max2}) do
    compare(max1, max2)
  end

  defp compare(value1, value2) do
    cond do
      value1 < value2 -> :lt
      value1 == value2 -> :eq
      :otherwise -> :gt
    end
  end

  defimpl Hallux.Protocol.Monoid do
    alias Hallux.Internal.OrderedHashBounds

    def mempty(_) do
      OrderedHashBounds.new()
    end

    def mappend(
          %OrderedHashBounds{order: order1, min: min1, max: max1},
          %OrderedHashBounds{order: order2, min: min2, max: max2}
        ) do
      order =
        case OrderedHashBounds.compare_order(order1, order2) do
          :lt -> order2
          _ -> order1
        end

      %OrderedHashBounds{
        order: order,
        min: min(min1, min2),
        max: max(max1, max2)
      }
    end
  end
end
