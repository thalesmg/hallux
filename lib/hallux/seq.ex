defmodule Hallux.Seq do
  defstruct [:t]

  alias Hallux.Internal.Elem
  alias Hallux.Internal.FingerTree
  alias Hallux.Internal.FingerTree.Deep
  alias Hallux.Internal.FingerTree.Empty
  alias Hallux.Internal.FingerTree.Single
  alias Hallux.Protocol.Measured
  alias Hallux.Protocol.Reduce
  alias Hallux.Internal.Size

  def new(), do: %__MODULE__{t: %Empty{monoid: Size}}

  def new(enum, transform \\ & &1) do
    Enum.reduce(enum, new(), fn x, acc ->
      snoc(acc, transform.(x))
    end)
  end

  def empty?(%__MODULE__{t: t}), do: Measured.size(t) == %Size{s: 0}

  def cons(%__MODULE__{t: t}, a), do: %__MODULE__{t: FingerTree.cons(t, %Elem{e: a})}
  def snoc(%__MODULE__{t: t}, a), do: %__MODULE__{t: FingerTree.snoc(t, %Elem{e: a})}

  def take(%__MODULE__{t: t}, n),
    do: %__MODULE__{t: FingerTree.take_until(t, fn %Size{s: s} -> s > n end)}

  def drop(%__MODULE__{t: t}, n),
    do: %__MODULE__{t: FingerTree.drop_until(t, fn %Size{s: s} -> s > n end)}

  def reducer(seq = %__MODULE__{}, acc, rfn), do: Reduce.reducer(seq, acc, rfn)
  def reducel(seq = %__MODULE__{}, acc, lfn), do: Reduce.reducel(seq, acc, lfn)

  def view_l(%__MODULE__{t: t}) do
    with {%Elem{e: x}, rest} <- FingerTree.view_l(t) do
      {x, %__MODULE__{t: rest}}
    end
  end

  def view_r(%__MODULE__{t: t}) do
    with {%Elem{e: x}, rest} <- FingerTree.view_r(t) do
      {x, %__MODULE__{t: rest}}
    end
  end

  def slice(seq = %__MODULE__{}, from..to) when is_integer(from) and is_integer(to) do
    seq
    |> drop(from)
    |> take(to - from + 1)
  end

  defimpl Hallux.Protocol.Reduce do
    alias Hallux.Internal.Elem
    alias Hallux.Protocol.Reduce
    alias Hallux.Seq

    def reducer(%Seq{t: t}, acc, rfn) do
      Reduce.reducer(t, acc, fn %Elem{e: e}, acc -> rfn.(e, acc) end)
    end

    def reducel(%Seq{t: t}, acc, lfn) do
      Reduce.reducel(t, acc, fn %Elem{e: e}, acc -> lfn.(e, acc) end)
    end
  end

  defimpl Enumerable do
    alias Hallux.Internal.FingerTree
    alias Hallux.Internal.Size
    alias Hallux.Protocol.Measured
    alias Hallux.Protocol.Reduce
    alias Hallux.Seq

    def count(%Seq{t: t}), do: {:ok, Measured.size(t)}

    def member?(_, _), do: {:error, __MODULE__}

    def reduce(_seq, {:halt, acc}, _fun), do: {:halted, acc}
    def reduce(seq, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(seq, &1, fun)}

    def reduce(%Seq{t: t}, {:cont, acc}, fun) do
      case FingerTree.view_l(t) do
        nil -> {:done, acc}
        {%Elem{e: x}, rest} -> reduce(%Seq{t: rest}, fun.(x, acc), fun)
      end
    end

    def slice(seq = %Seq{t: t}) do
      %Size{s: size} = Measured.size(t)

      slicing_fun = fn start, len ->
        %Seq{t: t_} =
          seq
          |> Seq.drop(start)
          |> Seq.take(len)

        Reduce.reducer(t_, [], &[&1.e | &2])
      end

      {:ok, size, slicing_fun}
    end
  end

  defimpl Collectable do
    alias Hallux.Seq

    def into(original) do
      collector_fn = fn
        seq, {:cont, elem} -> Seq.snoc(seq, elem)
        seq, :done -> seq
        _seq, :halt -> :ok
      end

      {original, collector_fn}
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(seq, opts) do
      opts = %Inspect.Opts{opts | charlists: :as_lists}

      concat([
        "#HalluxSeq<",
        Inspect.List.inspect(Enum.to_list(seq), opts),
        ">"
      ])
    end
  end
end
