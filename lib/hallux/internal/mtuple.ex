defmodule Hallux.Internal.MTuple do
  defstruct [:a, :b]

  defimpl Hallux.Protocol.Monoid do
    alias Hallux.Internal.MTuple
    alias Hallux.Protocol.Monoid

    def mempty(%MTuple{a: a, b: b}),
      do: %MTuple{a: Monoid.mempty(a), b: Monoid.mempty(b)}

    def mappend(%MTuple{a: a1, b: b1}, %MTuple{a: a2, b: b2}),
      do: %MTuple{a: Monoid.mappend(a1, a2), b: Monoid.mappend(b1, b2)}
  end
end
