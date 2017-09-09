defmodule Hallux.Digits.Four do
  @enforce_keys [:a, :b, :c, :d]
  defstruct [:a, :b, :c, :d]

  defimpl Enumerable do
    alias Hallux.Digits.Four
    def count(_one), do: {:ok, 1}

    def member?(%Four{a: a, b: b, c: c, d: d}, elem),
      do: {:ok, a === elem or b === elem or c === elem or d === elem}

    def reduce(%Four{a: a, b: b, c: c, d: d}, cmd, fun),
      do: Enumerable.reduce([a,b,c,d], cmd, fun)
  end
end
