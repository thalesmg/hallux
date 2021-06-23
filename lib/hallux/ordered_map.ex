defmodule Hallux.OrderedMap do
  @moduledoc """
  An ordered sequence that is also a hashmap on values.

  * Items consist of a value and an order key.
    Values are hashed.
  * The sequence is always sorted by the order,
    new items are inserted at their order position.
  * Values can be retrieved in O(log(n)) if addressed by order key.
  * All keys to an item can be retrieved in O(m*log(n)),
    where m is the number of occurrences of that value.
    (Currently, hash collisions are not checked.)
  """

  alias Hallux.Internal.FingerTree
  alias Hallux.Internal.FingerTree.Empty
  alias Hallux.Internal.OrderedHashBounds
  alias Hallux.Internal.OrderedHashBounds.Order

  defstruct [:finger_tree]

  @doc """
  `(O(1))`. Returns an empty `OrderedMap`.

  ## Examples

      iex> new()
      #HalluxOrderedMap<[]>
  """
  def new() do
    %__MODULE__{finger_tree: empty()}
  end

  @doc """
  `(O(n log(n)))`. Returns an `OrderedMap` filled with the list of key-value-pairs.

  ## Examples

      iex> new([{1, "hai"}]) |> Enum.to_list()
      [{1, "hai"}]
      iex> new([{23, 5}, {1, "hai"}, {"something", [:some, :thing]}, {:foo, "foo"}])
      #HalluxOrderedMap<[{1, "hai"}, {23, 5}, {:foo, "foo"}, {"something", [:some, :thing]}]>
  """
  def new(key_value_list) do
    Enum.into(key_value_list, new())
  end

  @doc """
  Split according to the order key.

  ## Examples

      iex> my_map = new([b: "b1", a: "a", c: "c", b: "b2"])
      #HalluxOrderedMap<[a: "a", b: "b1", b: "b2", c: "c"]>
      iex> {a, b, c} = split(my_map, :b)
      iex> a
      #HalluxOrderedMap<[a: "a"]>
      iex> b
      #HalluxOrderedMap<[b: "b1", b: "b2"]>
      iex> c
      #HalluxOrderedMap<[c: "c"]>
  """
  def split(%__MODULE__{finger_tree: finger_tree}, key) do
    {smaller, greater_or_equal} =
      FingerTree.split(
        finger_tree,
        fn %OrderedHashBounds{order: order} ->
          OrderedHashBounds.compare_order(order, %Order{order: key}) in [:eq, :gt]
        end
      )

    {equal, greater} =
      FingerTree.split(
        greater_or_equal,
        fn %OrderedHashBounds{order: order} ->
          OrderedHashBounds.compare_order(order, %Order{order: key}) == :gt
        end
      )

    {%__MODULE__{finger_tree: smaller}, %__MODULE__{finger_tree: equal},
     %__MODULE__{finger_tree: greater}}
  end

  @doc """
  Get an ordered map of all values with the given order key.

    ## Examples

      iex> my_map = new([b: "b1", a: "a", c: "c", b: "b2"])
      #HalluxOrderedMap<[a: "a", b: "b1", b: "b2", c: "c"]>
      iex> get(my_map, :b)
      #HalluxOrderedMap<[b: "b1", b: "b2"]>
  """
  def get(ordered_hash_bounds_queue, key) do
    {_, equal, _} = split(ordered_hash_bounds_queue, key)
    equal
  end

  @doc """
  Insert a value and key.

  ## Examples

      iex> my_map = new([b: "b1", a: "a", c: "c", b: "b2"])
      #HalluxOrderedMap<[a: "a", b: "b1", b: "b2", c: "c"]>
      iex> insert(my_map, :a, "A")
      #HalluxOrderedMap<[a: "a", a: "A", b: "b1", b: "b2", c: "c"]>
  """
  def insert(ordered_hash_bounds_queue, key, value) do
    {smaller, equal, greater} = split(ordered_hash_bounds_queue, key)

    %__MODULE__{
      finger_tree:
        smaller.finger_tree
        |> FingerTree.concat(equal.finger_tree)
        |> FingerTree.snoc(OrderedHashBounds.Value.new(key, value))
        |> FingerTree.concat(greater.finger_tree)
    }
  end

  @doc """
  Find all entries with a given value.

  ## Examples

      iex> my_map = new([b: "yes", a: "no", c: "no", d: "yes", b: "no", e: "no"])
      #HalluxOrderedMap<[a: "no", b: "yes", b: "no", c: "no", d: "yes", e: "no"]>
      iex> filter_value(my_map, "yes")
      #HalluxOrderedMap<[b: "yes", d: "yes"]>
  """
  def filter_value(%__MODULE__{finger_tree: finger_tree}, value) do
    %__MODULE__{
      finger_tree: filter_value_finger_tree(finger_tree, OrderedHashBounds.hash(value), empty())
    }
  end

  defp filter_value_finger_tree(%Empty{}, _, accum) do
    accum
  end

  defp filter_value_finger_tree(finger_tree, hash, accum) do
    {_smaller, greater_or_equal} =
      FingerTree.split(
        finger_tree,
        fn %OrderedHashBounds{max: max} -> hash <= max end
      )

    {greater_or_equal, smaller} =
      FingerTree.split(
        greater_or_equal,
        fn %OrderedHashBounds{min: min} -> hash > min end
      )

    equal = filter_value_among_geq(greater_or_equal, hash, empty())

    filter_value_finger_tree(smaller, hash, FingerTree.concat(accum, equal))
  end

  defp filter_value_among_geq(%Empty{}, _, accum) do
    accum
  end

  defp filter_value_among_geq(finger_tree, hash, accum) do
    {equal, greater} =
      FingerTree.split(
        finger_tree,
        fn %OrderedHashBounds{max: max} -> hash < max end
      )

    {_greater, equal_or_greater} =
      FingerTree.split(
        greater,
        fn %OrderedHashBounds{min: min} -> hash >= min end
      )

    filter_value_among_geq(equal_or_greater, hash, FingerTree.concat(accum, equal))
  end

  defp empty() do
    %Empty{monoid: OrderedHashBounds.new()}
  end

  @doc """
  Return a list of all keys, in order.

  ## Examples

      iex> ordered_map = OrderedMap.new([a: 1, c: 3, b: 2, b: 4])
      #HalluxOrderedMap<[a: 1, b: 2, b: 4, c: 3]>
      iex> keys(ordered_map)
      [:a, :b, :b, :c]
  """
  def keys(ordered_map) do
    ordered_map
    |> Enum.map(fn {key, _value} -> key end)
  end

  @doc """
  Return a list of all values, in order of the keys.

  ## Examples

      iex> ordered_map = OrderedMap.new([a: 1, c: 3, b: 2, b: 4])
      #HalluxOrderedMap<[a: 1, b: 2, b: 4, c: 3]>
      iex> values(ordered_map)
      [1, 2, 4, 3]
  """
  def values(ordered_map) do
    ordered_map
    |> Enum.map(fn {_key, value} -> value end)
  end

  defimpl Enumerable do
    alias Hallux.Internal.FingerTree
    alias Hallux.OrderedMap

    def count(_), do: {:error, __MODULE__}

    def member?(_, _), do: {:error, __MODULE__}

    def slice(_), do: {:error, __MODULE__}

    def reduce(_ordered_map, {:halt, acc}, _fun), do: {:halted, acc}

    def reduce(ordered_map, {:suspend, acc}, fun),
      do: {:suspended, acc, &reduce(ordered_map, &1, fun)}

    def reduce(%OrderedMap{finger_tree: finger_tree}, {:cont, acc}, fun) do
      case FingerTree.view_l(finger_tree) do
        nil ->
          {:done, acc}

        {%OrderedHashBounds.Value{
           value: value,
           ordered_hash_bounds: %OrderedHashBounds{order: %Order{order: order}}
         }, rest} ->
          reduce(
            %OrderedMap{finger_tree: rest},
            fun.({order, value}, acc),
            fun
          )
      end
    end
  end

  defimpl Collectable do
    alias Hallux.OrderedMap

    def into(original) do
      collector_fn = fn
        ordered_map, {:cont, {key, value}} -> OrderedMap.insert(ordered_map, key, value)
        ordered_map, :done -> ordered_map
        _finger_tree, :halt -> :ok
      end

      {original, collector_fn}
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(ordered_map, opts) do
      opts = %Inspect.Opts{opts | charlists: :as_lists}

      concat([
        "#HalluxOrderedMap<",
        Inspect.List.inspect(Enum.to_list(ordered_map), opts),
        ">"
      ])
    end
  end
end
