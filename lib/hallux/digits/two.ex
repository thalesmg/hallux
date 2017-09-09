defmodule Hallux.Digits.Two do
  @enforce_keys [:a, :b]
  defstruct [:a, :b]

  defimpl Enumerable do
    alias Hallux.Digits.Two
    def count(_one), do: {:ok, 1}

    def member?(%Two{a: a, b: b}, elem), do: {:ok, a === elem or b === elem}

    def reduce(%Two{a: a, b: b}, cmd, fun),
      do: Enumerable.reduce([a,b], cmd, fun)
  end
end
