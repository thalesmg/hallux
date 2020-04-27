defmodule Hallux.Internal.Prio do
  alias Hallux.Internal.Prio.MInfty
  alias Hallux.Internal.Prio.Prio

  def compare(%MInfty{}, %MInfty{}), do: :eq
  def compare(%MInfty{}, %Prio{}), do: :lt
  def compare(%Prio{}, %MInfty{}), do: :gt

  def compare(%Prio{p: p1}, %Prio{p: p2}) do
    cond do
      p1 < p2 -> :lt
      p1 > p2 -> :gt
      :otherwise -> :eq
    end
  end
end
