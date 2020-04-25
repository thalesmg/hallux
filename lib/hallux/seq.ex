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

  # def take(seq = %__MODULE__{t: t}, i) when is_integer(i) do
  #   cond do
  #     (i - 1) < (Measured.size(t) - 1) ->
  #       :take

  #     i <= 0 ->
  #       new()

  #     :otherwise ->
  #       seq
  #   end
  # end

  # defp take_tree_e(_, t = %Empty{}), do: t
  # defp take_tree_e(i, t = %Single{monoid: mo}) when i <= 0, do: %Empty{monoid: mo}
  # defp take_tree_e(_, t = %Single{}), do: t
  # defp take_tree_e(i, t = %Deep{size: s, l: pr, m: m, r: sf}) do
  #   spr = Measured.size(pr).s
  #   spm = spr + Measured.size(m).s
  #   im = i - spr

  #   cond do
  #     i < spr ->
  #       take_prefix_e(i, pr)

  #     i < spm ->
  #       {ml, xs} = take_tree_n(im, m)
  #       take_middle_e(im - Measured.size(ml).s, spr, pr, ml, xs)

  #     :otherwise ->
  #       take_suffix_e(i - spm, s, pr, m, sf)
  #   end
  # end

  # defp take_tree_n(_, %Empty{}), do: raise "take_tree_n of empty tree"
  # defp take_tree_n(i, %Single{monoid: mo, x: x}), do: {%Empty{monoid: mo}, x}
  # defp take_tree_n(i, %Deep{size: s, l: pr, m: m, r: sf}) do
  #   spr = Measured.size(pr).s
  #   spm = spr + Measured.size(m).s
  #   im = i - spr

  #   cond do
  #     i < spr ->
  #       take_prefix_n(i, pr)

  #     i < spm ->
  #       {ml, xs} = take_tree_n(im, m)
  #       take_middle_n(im - Measured.size(ml).s, spr, pr, ml, xs)

  #     :otherwise ->
  #       take_suffix_n(i - spm, s, pr, m, sf)
  #   end
  # end

  # defp take_middle_n(i, spr, pr, ml, %Node2{l: a, r: b}) do
  #   sa = Measured.size(a).s
  #   sprml = spr + Measured.size(ml).s
  #   sprmla = sa + sprml

  #   if  i < sa do
  #     {pull_r(s - sa - Measured.size(b).s, pr, m), a}
  #   else
  #     {%Deep{monoid: Size, size: s - Measured.size(b).s, l: pr, m: m, r: %One{a: a}}, b}
  #   end
  # end

  defimpl Enumerable do
    alias Hallux.Protocol.Measured
    alias Hallux.Seq

    def count(%Seq{t: t}), do: {:ok, Measured.size(t)}
  end
end
