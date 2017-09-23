defmodule Hallux.Node2 do
  defstruct [:l, :r, :__size__]

  defimpl Hallux.Measured do
    alias Hallux.Node2

    def size(%Node2{__size__: s}, _, _, _), do: s
  end
end

defmodule Hallux.Node3 do
  defstruct [:l, :m, :r, :__size__]

  defimpl Hallux.Measured do
    alias Hallux.Node3

    def size(%Node3{__size__: s}, _, _, _), do: s
  end
end

defmodule Hallux.Node do
  alias Hallux.Digits.{One, Two, Three, Four}
  alias Hallux.{Node2, Node3}
  import Hallux, only: [node2: 5, node3: 6]

  def to_digit(%Node2{l: l, r: r}), do: %Two{a: l, b: r}
  def to_digit(%Node3{l: l, m: m, r: r}), do: %Three{a: l, b: m, c: r}

  def to_nodes([a,b], zero, measure, reduce),
    do: [node2(a,b, zero, measure, reduce)]
  def to_nodes([a,b,c], zero, measure, reduce),
    do: [node3(a,b,c, zero, measure, reduce)]
  def to_nodes([a,b,c,d], zero, measure, reduce),
    do: [node2(a,b, zero, measure, reduce), node2(c,d, zero, measure, reduce)]
  def to_nodes([a,b,c|rest], zero, measure, reduce),
    do: [node3(a,b,c, zero, measure, reduce) | to_nodes(rest, zero, measure, reduce)]

end
