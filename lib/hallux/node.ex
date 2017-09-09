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
  import Hallux, only: [node2: 2, node3: 3]

  def to_digit(%Node2{l: l, r: r}), do: %Two{a: l, b: r}
  def to_digit(%Node3{l: l, m: m, r: r}), do: %Three{a: l, b: m, c: r}

  def to_nodes([a,b]), do: [node2(a,b)]
  def to_nodes([a,b,c]), do: [node3(a,b,c)]
  def to_nodes([a,b,c,d]), do: [node2(a,b), node2(c,d)]
  def to_nodes([a,b,c|rest]), do: [node3(a,b,c) | to_nodes(rest)]

end
