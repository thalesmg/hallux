defmodule Hallux.Test.Generators do
  use ExUnitProperties

  alias Hallux.IntervalMap
  alias Hallux.Seq

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
end
