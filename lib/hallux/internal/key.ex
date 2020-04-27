defmodule Hallux.Internal.Key do
  alias Hallux.Internal.Key.Key
  alias Hallux.Internal.Key.NoKey

  def compare(%NoKey{}, %NoKey{}), do: :eq
  def compare(%NoKey{}, %Key{}), do: :lt
  def compare(%Key{}, %NoKey{}), do: :gt

  def compare(%Key{k: k1}, %Key{k: k2}) do
    cond do
      k1 < k2 -> :lt
      k1 > k2 -> :gt
      :otherwise -> :eq
    end
  end
end
