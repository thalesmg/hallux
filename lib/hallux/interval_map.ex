defmodule Hallux.IntervalMap do
  defstruct [:t]

  alias Hallux.Internal.FingerTree
  alias Hallux.Internal.FingerTree.Empty
  alias Hallux.Internal.Interval
  alias Hallux.Internal.IntInterval.IntInterval
  alias Hallux.Internal.IntInterval.NoInterval
  alias Hallux.Internal.Split
  alias Hallux.Protocol.Measured
  alias Hallux.Protocol.Monoid

  def new(),
    do: %__MODULE__{t: %Empty{monoid: %NoInterval{}}}

  def insert(interval_map, interval, payload \\ nil)
  def insert(im = %__MODULE__{}, {low, high}, _payload) when low > high, do: im

  def insert(%__MODULE__{t: t}, {low, high}, payload) do
    {l, r} =
      FingerTree.split(t, fn %IntInterval{i: k} ->
        k >= {low, high}
      end)

    %__MODULE__{
      t:
        FingerTree.concat(
          l,
          FingerTree.cons(
            r,
            %Interval{low: low, high: high, payload: payload}
          )
        )
    }
  end

  def interval_search(%__MODULE__{t: t = %_{monoid: mo}}, {low_i, high_i}) do
    %Split{x: %Interval{low: low_x, high: high_x, payload: payload}} =
      FingerTree.split_tree(&at_least(low_i, &1), Monoid.mempty(mo), t)

    if at_least(low_i, Measured.size(t)) and low_x <= high_i do
      {:ok, {low_x, high_x}, payload}
    else
      nil
    end
  end

  def interval_match(%__MODULE__{t: t}, {low_i, high_i}) do
    t
    |> FingerTree.take_until(&greater(high_i, &1))
    |> matches(low_i)
  end

  defp matches(xs, low_i) do
    xs
    |> FingerTree.drop_until(&at_least(low_i, &1))
    |> FingerTree.view_l()
    |> case do
      nil ->
        []

      {%Interval{low: low, high: high, payload: payload}, xs_} ->
        [{{low, high}, payload} | matches(xs_, low_i)]
    end
  end

  def at_least(k, %IntInterval{v: hi}) do
    k <= hi
  end

  def greater(k, %IntInterval{i: {low, _}}) do
    low > k
  end
end
