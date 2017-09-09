defmodule Hallux.Digits.Three do
  @enforce_keys [:a, :b, :c]
  defstruct [:a, :b, :c]

  defimpl Enumerable do
    alias Hallux.Digits.Three
    def count(_one), do: {:ok, 1}

    def member?(%Three{a: a, b: b, c: c}, elem),
      do: {:ok, a === elem or b === elem or c === elem}

    def reduce(%Three{a: a, b: b, c: c}, cmd, fun),
      do: Enumerable.reduce([a,b,c], cmd, fun)
  end
end
