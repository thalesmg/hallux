defmodule Hallux.Seq do
  defstruct [:t]

  alias Hallux.Internal.Elem
  alias Hallux.Internal.FingerTree
  alias Hallux.Internal.FingerTree.Deep
  alias Hallux.Internal.FingerTree.Empty
  alias Hallux.Internal.FingerTree.Single
  alias Hallux.Internal.Size
  alias Hallux.Protocol.Measured

  def new(), do: %__MODULE__{t: %Empty{monoid: Size}}
  def cons(%__MODULE__{t: t}, a), do: %__MODULE__{t: FingerTree.cons(t, %Elem{e: a})}
  def snoc(%__MODULE__{t: t}, a), do: %__MODULE__{t: FingerTree.snoc(t, %Elem{e: a})}

  def take(%__MODULE__{t: t}, n),
    do: %__MODULE__{t: FingerTree.take_until(t, fn %Size{s: s} -> s > n end)}

  def drop(%__MODULE__{t: t}, n),
    do: %__MODULE__{t: FingerTree.drop_until(t, fn %Size{s: s} -> s > n end)}

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
end
