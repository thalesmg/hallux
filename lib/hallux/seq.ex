defmodule Hallux.Seq do
  defstruct [:t]

  alias Hallux.Internal.FingerTree
  alias Hallux.Internal.FingerTree.Deep
  alias Hallux.Internal.FingerTree.Empty
  alias Hallux.Internal.FingerTree.Single
  alias Hallux.Internal.Size
  alias Hallux.Protocol.Measured

  def new(), do: %__MODULE__{t: %Empty{monoid: Size}}
  def cons(%__MODULE__{t: t}, a), do: %__MODULE__{t: FingerTree.cons(t, a)}
  def snoc(%__MODULE__{t: t}, a), do: %__MODULE__{t: FingerTree.snoc(t, a)}

  defimpl Enumerable do
    alias Hallux.Protocol.Measured
    alias Hallux.Seq

    def count(%Seq{t: t}), do: {:ok, Measured.size(t)}
  end
end
