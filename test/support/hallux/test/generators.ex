defmodule Hallux.Test.Generators do
  use ExUnitProperties

  alias Hallux.IntervalMap
  alias Hallux.Seq
  alias Hallux.OrderedMap

  def seq(generator \\ term()) do
    gen all(xs <- list_of(generator)) do
      Seq.new(xs)
    end
  end

  def interval_map() do
    gen all(
          is <- list_of(interval()),
          size = length(is),
          payloads <- list_of(term(), length: size)
        ) do
      is
      |> Stream.zip(payloads)
      |> Enum.reduce(IntervalMap.new(), &IntervalMap.insert(&2, &1))
    end
  end

  def interval() do
    gen all(bounds <- list_of(integer(), length: 2)) do
      [x, y] = Enum.sort(bounds)
      {x, y}
    end
  end

  def disjoint_intervals() do
    gen all(xs <- list_of(integer())) do
      xs
      |> Enum.sort()
      |> Enum.dedup()
      |> Stream.chunk_every(2, 2, :discard)
      |> Enum.map(fn [x, y] -> {x, y} end)
    end
  end

  def ordered_map(key_gen \\ term(), value_gen \\ term()) do
    gen all(key_value_pairs <- list_of(tuple({key_gen, value_gen}))) do
      OrderedMap.new(key_value_pairs)
    end
  end
end
