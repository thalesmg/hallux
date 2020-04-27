defmodule Hallux.Internal.MTuple do
  defstruct [:a, :b]

  alias Hallux.Internal.Key, as: KeyBase
  alias Hallux.Internal.Key.Key
  alias Hallux.Internal.Prio, as: PrioBase
  alias Hallux.Internal.Prio.Prio

  def new({l, h}) do
    %__MODULE__{a: %Key{k: l}, b: %Prio{p: h}}
  end

  def compare(%__MODULE__{a: key1, b: prio1}, %__MODULE__{a: key2, b: prio2}) do
    case {KeyBase.compare(key1, key2), PrioBase.compare(prio1, prio2)} do
      {:lt, _} -> :lt
      {:gt, _} -> :gt
      {:eq, cmp} -> cmp
    end
  end

  defimpl Hallux.Protocol.Monoid do
    alias Hallux.Internal.MTuple
    alias Hallux.Protocol.Monoid

    def mempty(%MTuple{a: a, b: b}),
      do: %MTuple{a: Monoid.mempty(a), b: Monoid.mempty(b)}

    def mappend(%MTuple{a: a1, b: b1}, %MTuple{a: a2, b: b2}),
      do: %MTuple{a: Monoid.mappend(a1, a2), b: Monoid.mappend(b1, b2)}
  end
end
