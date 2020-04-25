defmodule Hallux.Seq do
  defstruct [:t]

  alias Hallux.Internal.FingerTree
  alias Hallux.Internal.FingerTree.Deep
  alias Hallux.Internal.FingerTree.Empty
  alias Hallux.Internal.FingerTree.Single
  alias Hallux.Internal.Size

  def empty(), do: %__MODULE__{t: %Empty{monoid: Size}}
  def cons(%__MODULE__{t: t}, a), do: %__MODULE__{t: FingerTree.cons(t, a)}
  def snoc(%__MODULE__{t: t}, a), do: %__MODULE__{t: FingerTree.snoc(t, a)}

  defimpl Enumerable do
    alias Hallux.Internal.FingerTree.Deep
    alias Hallux.Internal.FingerTree.Empty
    alias Hallux.Internal.FingerTree.Single
    alias Hallux.Seq

    def count(%Seq{t: %Empty{}}), do: {:ok, 0}
    def count(%Seq{t: %Single{}}), do: {:ok, 1}
    def count(%Seq{t: %Deep{size: %Size{s: s}}}), do: {:ok, s}

    def slice(seq = %Seq{t: %Empty{}}) do
      {:ok, count(seq), fun}
    end
  end
end
