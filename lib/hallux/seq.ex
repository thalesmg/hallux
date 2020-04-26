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
    alias Hallux.Protocol.Measured
    alias Hallux.Seq

    def count(%Seq{t: t}), do: {:ok, Measured.size(t)}
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
