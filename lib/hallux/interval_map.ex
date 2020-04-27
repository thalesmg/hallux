defmodule Hallux.IntervalMap do
  defstruct [:t]

  alias Hallux.Internal.FingerTree
  alias Hallux.Internal.FingerTree.Empty
  alias Hallux.Internal.Interval
  alias Hallux.Internal.Key, as: KeyBase
  alias Hallux.Internal.Key.Key
  alias Hallux.Internal.Key.NoKey
  alias Hallux.Internal.MTuple
  alias Hallux.Internal.Prio, as: PrioBase
  alias Hallux.Internal.Prio.MInfty
  alias Hallux.Internal.Prio.Prio
  alias Hallux.Internal.Split
  alias Hallux.Protocol.Measured
  alias Hallux.Protocol.Monoid

  def new(),
    do: %__MODULE__{t: %Empty{monoid: %MTuple{a: %NoKey{}, b: %MInfty{}}}}

  def insert(%__MODULE__{t: t}, {l, h}, payload \\ nil) do
    {l, r} = FingerTree.split(t, fn  end)
    %__MODULE__{t: FingerTree.snoc(t, %Interval{low: l, high: h, payload: payload})}
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

  defp at_least(k, %MTuple{b: prio}) do
    PrioBase.compare(%Prio{p: k}, prio) != :gt
  end

  defp greater(k, %MTuple{a: key}) do
    IO.inspect(binding(), label: :greater)
    (KeyBase.compare(key, %Key{k: k}) == :gt)
    |> IO.inspect(label: :greater_res)
  end
end
