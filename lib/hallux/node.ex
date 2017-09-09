defmodule Hallux.Node2 do
  defstruct [:l, :r]
end

defmodule Hallux.Node3 do
  defstruct [:l, :m, :r]
end

defmodule Hallux.Node do
  alias Hallux.Digits.{One, Two, Three, Four}
  alias Hallux.{Node2, Node3}

  def to_digit(%Node2{l: l, r: r}), do: %Two{a: l, b: r}
  def to_digit(%Node3{l: l, m: m, r: r}), do: %Three{a: l, b: m, c: r}
end
