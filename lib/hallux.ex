defmodule Hallux do
  alias __MODULE__.Views
  alias __MODULE__.Digits.{One, Two, Three, Four}
  alias __MODULE__.{Node2, Node3}

  defmodule Empty, do: (defstruct [])
  defmodule Single, do: (defstruct [:v])
  defmodule Deep, do: (defstruct [:pr, :m, :sf])

  def empty(), do: %__MODULE__.Empty{}
  def single(x), do: %__MODULE__.Single{v: x}
  def deep(pr, m, sf), do: %__MODULE__.Deep{pr: pr, m: m, sf: sf}

  def one(a), do: %One{a: a}
  def two(a, b), do: %Two{a: a, b: b}
  def three(a, b, c), do: %Three{a: a, b: b, c: c}
  def four(a, b, c, d), do: %Four{a: a, b: b, c: c, d: d}

  def node2(l, r), do: %Node2{l: l, r: r}
  def node3(l, m, r), do: %Node3{l: l, m: m, r: r}

  def cons(%__MODULE__.Empty{}, y), do: single(y)
  def cons(%__MODULE__.Single{v: v}, y), do: deep(one(y), empty(), one(v))
  def cons(%__MODULE__.Deep{pr: pr, m: m, sf: sf}, y) do
    case pr do
      %One{a: a} ->
        deep(two(y, a), m, sf)
      %Two{a: a, b: b} ->
        deep(three(y, a, b), m, sf)
      %Three{a: a, b: b, c: c} ->
        deep(four(y, a, b, c), m, sf)
      %Four{a: a, b: b, c: c, d: d} ->
        deep(two(y, a), cons(m, node3(b, c, d)), sf)
    end
  end

  def snoc(%__MODULE__.Empty{}, y), do: single(y)
  def snoc(%__MODULE__.Single{v: v}, y), do: deep(one(v), empty(), one(y))
  def snoc(%__MODULE__.Deep{pr: pr, m: m, sf: sf}, y) do
    case sf do
      %One{a: a} ->
        deep(pr, m, two(a, y))
      %Two{a: a, b: b} ->
        deep(pr, m, three(a, b, y))
      %Three{a: a, b: b, c: c} ->
        deep(pr, m, four(a, b, c, y))
      %Four{a: a, b: b, c: c, d: d} ->
        deep(pr, snoc(m, node3(a, b, c)), two(d, y))
    end
  end

  def reduceL(finger_tree, xs) do
    xs = Enum.reverse(xs)
    Enum.reduce(xs, finger_tree, & cons(&2, &1))
  end

  def reduceR(finger_tree, xs) do
    Enum.reduce(xs, finger_tree, & snoc(&2, &1))
  end

  def to_tree(xs) do
    reduceL(empty(), xs)
  end

  def viewL(%__MODULE__.Empty{}), do: Views.nilL()
  def viewL(%__MODULE__.Single{v: v}), do: Views.consL(v, empty())
  def viewL(%__MODULE__.Deep{pr: pr, m: m, sf: sf}) do
    case pr do
      %One{a: a} ->
        case viewL m do
          %Views.NilL{} ->
            Views.consL(a, to_tree(sf))
          %Views.ConsL{hd: hd, tl: tl} ->
            Views.consL(a, deep(one(hd), tl, sf))
        end
      %Two{a: a, b: b} ->
        Views.consL(a, deep(one(b), m, sf))
      %Three{a: a, b: b, c: c} ->
        Views.consL(a, deep(two(b, c), m, sf))
      %Four{a: a, b: b, c: c, d: d} ->
        Views.consL(a, deep(three(b, c, d), m, sf))
    end
  end

end
