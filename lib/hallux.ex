defmodule Hallux do
  alias __MODULE__.Views
  alias __MODULE__.Digits
  alias __MODULE__.Digits.{One, Two, Three, Four}
  alias __MODULE__.{Node, Node2, Node3}

  alias __MODULE__.Measured

  defmodule Empty do
    defstruct []

    defimpl Hallux.Measured do
      alias Hallux.Empty

      def size(empty, z, _measure, _reduce),
        do: z
    end
  end

  defmodule Single do
    defstruct [:v]

    defimpl Hallux.Measured do
      alias Hallux.Single
      alias Hallux.Measured

      def size(%Single{v: v}, z, measure, reduce),
        do: Measured.size(v, z, measure, reduce)
    end
  end

  defmodule Deep do
    defstruct [:pr, :m, :sf, :__size__]

    defimpl Hallux.Measured do
      alias Hallux.Deep

      def size(%Deep{__size__: s}, _, _, _), do: s
    end
  end

  defp measure_fn, do: fn _ -> 1 end
  defp reduce_fn, do: &+/2

  def empty(), do: %__MODULE__.Empty{}
  def single(x), do: %__MODULE__.Single{v: x}
  def deep(pr, m, sf, z \\ 0, measure \\ measure_fn(), reduce \\ reduce_fn()) do
    s = [
      Measured.size(pr, z, measure, reduce),
      Measured.size(m, z, measure, reduce),
      Measured.size(sf, z, measure, reduce)
    ]
    |> Enum.reduce(z, reduce)

    %__MODULE__.Deep{pr: pr, m: m, sf: sf, __size__: s}
  end

  def deepL(maybe_pr, m, sf, z \\ 0, measure \\ measure_fn(), reduce \\ reduce_fn())
  def deepL([], m, sf, z, measure, reduce) do
    case viewL m do
      %Views.NilL{} ->
        to_tree(sf, z, measure, reduce)
      %Views.ConsL{hd: hd, tl: tl} ->
        deep(Node.to_digit(hd), tl, sf, z, measure, reduce)
    end
  end
  def deepL(digit, m, sf, z, measure, reduce) do
    deep(Digits.to_digits(digit), m, sf, z, measure, reduce)
  end

  def deepR(pr, m, maybe_sf, z \\ 0, measure \\ measure_fn(), reduce \\ reduce_fn())
  def deepR(pr, m, [], z, measure, reduce) do
    case viewR m do
      %Views.NilR{} ->
        to_tree(pr, z, measure, reduce)
      %Views.ConsR{hd: hd, tl: tl} ->
        deep(pr, tl, Node.to_digit(hd), z, measure, reduce)
    end
  end
  def deepR(pr, m, digit, z, measure, reduce) do
    deep(pr, m, Digits.to_digits(digit), z, measure, reduce)
  end

  def one(a), do: %One{a: a}
  def two(a, b), do: %Two{a: a, b: b}
  def three(a, b, c), do: %Three{a: a, b: b, c: c}
  def four(a, b, c, d), do: %Four{a: a, b: b, c: c, d: d}

  def node2(l, r, z \\ 0, measure \\ measure_fn(), reduce \\ reduce_fn()) do
    s = Measured.size([l, r], z, measure, reduce)
    %Node2{l: l, r: r, __size__: s}
  end
  def node3(l, m, r, z \\ 0, measure \\ measure_fn(), reduce \\ reduce_fn()) do
    s = Measured.size([l, m, r], z, measure, reduce)
    %Node3{l: l, m: m, r: r, __size__: s}
  end

  def cons(tree, elem, zero \\ 0, measure \\ measure_fn(), reduce \\ reduce_fn())
  def cons(%__MODULE__.Empty{}, y, _, _, _), do: single(y)
  def cons(%__MODULE__.Single{v: v}, y, zero, measure, reduce),
    do: deep(one(y), empty(), one(v), zero, measure, reduce)
  def cons(%__MODULE__.Deep{pr: pr, m: m, sf: sf}, y, zero, measure, reduce) do
    case pr do
      %One{a: a} ->
        deep(two(y, a), m, sf, zero, measure, reduce)
      %Two{a: a, b: b} ->
        deep(three(y, a, b), m, sf, zero, measure, reduce)
      %Three{a: a, b: b, c: c} ->
        deep(four(y, a, b, c), m, sf, zero, measure, reduce)
      %Four{a: a, b: b, c: c, d: d} ->
        deep(two(y, a),
          cons(m, node3(b, c, d, zero, measure, reduce), zero, measure, reduce),
          sf, zero, measure, reduce)
    end
  end

  def snoc(tree, elem, zero \\ 0, measure \\ measure_fn(), reduce \\ reduce_fn())
  def snoc(%__MODULE__.Empty{}, y, _, _, _), do: single(y)
  def snoc(%__MODULE__.Single{v: v}, y, zero, measure, reduce),
    do: deep(one(v), empty(), one(y), zero, measure, reduce)
  def snoc(%__MODULE__.Deep{pr: pr, m: m, sf: sf}, y, zero, measure, reduce) do
    case sf do
      %One{a: a} ->
        deep(pr, m, two(a, y), zero, measure, reduce)
      %Two{a: a, b: b} ->
        deep(pr, m, three(a, b, y), zero, measure, reduce)
      %Three{a: a, b: b, c: c} ->
        deep(pr, m, four(a, b, c, y), zero, measure, reduce)
      %Four{a: a, b: b, c: c, d: d} ->
        deep(pr,
          snoc(m, node3(a, b, c, zero, measure, reduce), zero, measure, reduce),
          two(d, y), zero, measure, reduce)
    end
  end

  def reduceL(finger_tree, xs, zero \\ 0, measure \\ measure_fn(), reduce \\ reduce_fn()) do
    xs = Enum.reverse(xs)
    Enum.reduce(xs, finger_tree, & cons(&2, &1, zero, measure, reduce))
  end

  def reduceR(finger_tree, xs, zero \\ 0, measure \\ measure_fn(), reduce \\ reduce_fn()) do
    Enum.reduce(xs, finger_tree, & snoc(&2, &1, zero, measure, reduce))
  end

  def to_tree(xs, zero \\ 0, measure \\ measure_fn(), reduce \\ reduce_fn()) do
    reduceL(empty(), xs, zero, measure, reduce)
  end

  def to_list(tree) do
    case viewL(tree) do
      %Views.NilL{} -> []
      %Views.ConsL{hd: hd, tl: tl} ->
        [hd | to_list(tl)]
    end
  end

  def viewL(%__MODULE__.Empty{}), do: Views.nilL()
  def viewL(%__MODULE__.Single{v: v}), do: Views.consL(v, empty())
  def viewL(%__MODULE__.Deep{pr: pr, m: m, sf: sf}) do
    case pr do
      %One{a: a} ->
        rest = deepL([], m, sf)
        Views.consL(a, rest)
      %Two{a: a, b: b} ->
        Views.consL(a, deep(one(b), m, sf))
      %Three{a: a, b: b, c: c} ->
        Views.consL(a, deep(two(b, c), m, sf))
      %Four{a: a, b: b, c: c, d: d} ->
        Views.consL(a, deep(three(b, c, d), m, sf))
    end
  end

  def empty?(tree) do
    case viewL tree do
      %Views.NilL{} -> true
      %Views.ConsL{} -> false
    end
  end

  def headL(tree) do
    case viewL tree do
      %Views.ConsL{hd: hd} -> hd
    end
  end

  def tailL(tree) do
    case viewL tree do
      %Views.ConsL{tl: tl} -> tl
    end
  end

  def headR(tree) do
    case viewR tree do
      %Views.ConsR{hd: hd} -> hd
    end
  end

  def tailR(tree) do
    case viewR tree do
      %Views.ConsR{tl: tl} -> tl
    end
  end

  def viewR(%__MODULE__.Empty{}), do: Views.nilR()
  def viewR(%__MODULE__.Single{v: v}), do: Views.consR(v, empty())
  def viewR(%__MODULE__.Deep{pr: pr, m: m, sf: sf}) do
    case sf do
      %One{a: a} ->
        rest = deepR(pr, m, [])
        Views.consR(a, rest)
      %Two{a: a, b: b} ->
        Views.consR(b, deep(pr, m, one(a)))
      %Three{a: a, b: b, c: c} ->
        Views.consR(c, deep(pr, m, two(a,b)))
      %Four{a: a, b: b, c: c, d: d} ->
        Views.consR(d, deep(pr, m, three(a,b,c)))
    end
  end

  defp app3(%__MODULE__.Empty{}, ts, xs),
    do: reduceL(xs, ts)
  defp app3(xs, ts, %__MODULE__.Empty{}),
    do: reduceR(xs, ts)
  defp app3(%__MODULE__.Single{v: v}, ts, xs),
    do: reduceL(xs, ts) |> cons(v)
  defp app3(xs, ts, %__MODULE__.Single{v: v}),
    do: reduceR(xs, ts) |> snoc(v)
  defp app3(%__MODULE__.Deep{pr: pr1, m: m1, sf: sf1},
      ts,
      %__MODULE__.Deep{pr: pr2, m: m2, sf: sf2}) do
    lsf1 = Enum.to_list(sf1)
    lpr2 = Enum.to_list(pr2)

    deep(
      pr1,
      app3(m1, Node.to_nodes(lsf1 ++ ts ++ lpr2), m2),
      sf2
    )
  end

  def append(tree1, tree2) do
    app3(tree1, [], tree2)
  end

end
