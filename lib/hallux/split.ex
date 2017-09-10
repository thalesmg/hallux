defmodule Hallux.Split do
  defstruct [:l, :x, :r]

  alias Hallux
  alias Hallux.{Empty, Single, Deep}
  alias Hallux.Digits
  alias Hallux.Node
  alias Hallux.Digits.{One, Two, Three, Four}
  alias Hallux.Measured

  import Hallux, only: [
    empty: 0,
    deep: 3,
    deep: 6,
    deepL: 6,
    deepR: 6
  ]

  def split(%Empty{}, _predicate, _zero, _measure_fn, _reduce_fn), do: {empty(), empty()}
  def split(tree, predicate, zero, measure_fn, reduce_fn) when is_function(predicate, 1) do
    %__MODULE__{l: l, x: x, r: r} = split_tree(
        predicate, zero, tree, zero, measure_fn, reduce_fn)

    mtree = Measured.size(tree, zero, measure_fn, reduce_fn)
    if predicate.(mtree) do
      {l, Hallux.cons(r, x)}
    else
      {tree, empty()}
    end
  end

  def split_tree(_predicate, _acc, %Single{v: v}, zero, measure_fn, reduce_fn),
    do: %__MODULE__{l: empty(), x: v, r: empty()}
  def split_tree(predicate, acc, %Deep{} = tree, zero, measure_fn, reduce_fn) do
    %Deep{pr: pr, m: m, sf: sf} = tree
    vpr = Measured.size(pr, zero, measure_fn, reduce_fn)
    |> reduce_fn.(acc)
    vm =
      Measured.size(m, zero, measure_fn, reduce_fn)
      |> reduce_fn.(vpr)

    cond do
      predicate.(vpr) ->
        %__MODULE__{l: l, x: x, r: r} = split_digit(
            predicate, acc, pr, zero, measure_fn, reduce_fn)

        r_ = deepL(r, m, sf, zero, measure_fn, reduce_fn)
        %__MODULE__{l: Hallux.to_tree(l), x: x, r: r_}

      predicate.(vm) ->
        %__MODULE__{l: ml, x: xs, r: mr} = split_tree(
            predicate, vpr, m, zero, measure_fn, reduce_fn)
        ml_acc =
          Measured.size(ml, zero, measure_fn, reduce_fn)
          |> reduce_fn.(vpr)
        %__MODULE__{l: l, x: x, r: r} = split_digit(
            predicate, ml_acc, Node.to_digit(xs), zero, measure_fn, reduce_fn)

        l_ = deepR(pr, ml, l, zero, measure_fn, reduce_fn)
        r_ = deepL(r, mr, sf, zero, measure_fn, reduce_fn)
        %__MODULE__{l: l_, x: x, r: r_}


      :otherwise ->
        %__MODULE__{l: l, x: x, r: r} = split_digit(
            predicate, vm, sf, zero, measure_fn, reduce_fn)

        l_ = deepR(pr, m, l, zero, measure_fn, reduce_fn)
        %__MODULE__{l: l_, x: x, r: Hallux.to_tree(r)}
    end
  end

  def split_digit(_predicate, _acc, %One{a: a}, _, _, _),
    do: %__MODULE__{l: [], x: a, r: []}
  def split_digit(predicate, acc, digit, zero, measure_fn, reduce_fn) do
    {a, rest} = Digits.popL(digit)
    acc = Measured.size(a, zero, measure_fn, reduce_fn) |> reduce_fn.(acc)
    if predicate.(acc) do
      %__MODULE__{l: [], x: a, r: rest}
    else
      %__MODULE__{l: l, x: x, r: r} = split_digit(
        predicate, acc, Digits.to_digits(rest), zero, measure_fn, reduce_fn)

      %__MODULE__{l: [a | l], x: x, r: r}
    end
  end

end
