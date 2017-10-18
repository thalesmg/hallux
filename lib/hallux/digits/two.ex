defmodule Hallux.Digits.Two do
  @enforce_keys [:a, :b]
  defstruct [:a, :b]

  defimpl Enumerable do
    alias Hallux.Digits.Two
    def count(_one), do: {:ok, 1}

    def member?(%Two{a: a, b: b}, elem), do: {:ok, a === elem or b === elem}

    def reduce(%Two{a: a, b: b}, cmd, fun), do: Enumerable.reduce([a, b], cmd, fun)
  end

  defimpl Hallux.Measured do
    alias Hallux.Digits.Two
    alias Hallux.Measured

    def size(%Two{} = two, zero, measure_fn, reduce_fn)
        when is_function(measure_fn, 1) and is_function(reduce_fn, 2),
        do: Enum.to_list(two) |> Measured.size(zero, measure_fn, reduce_fn)
  end
end
