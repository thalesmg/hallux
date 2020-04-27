defmodule Hallux.Internal.IntInterval do
  alias Hallux.Internal.IntInterval.IntInterval
  alias Hallux.Internal.IntInterval.NoInterval

  def union(%NoInterval{}, i = %NoInterval{}), do: i
  def union(%NoInterval{}, i = %IntInterval{}), do: i
  def union(i = %IntInterval{}, %NoInterval{}), do: i
  def union(%IntInterval{v: hi1}, %IntInterval{i: i2, v: hi2}) do
    %IntInterval{i: i2, v: max(hi1, hi2)}
  end

  def compare(%NoInterval{}, %NoInterval{}), do: :eq
  def compare(%NoInterval{}, %IntInterval{}), do: :lt
  def compare(%IntInterval{}, %NoInterval{}), do: :lt
  def compare(%IntInterval{i: i1}, %IntInterval{i: i2}) do
    cond do
      i1 < i2 -> :lt
      i1 > i2 -> :gt
      :otherwise -> :eq
    end
  end
end
