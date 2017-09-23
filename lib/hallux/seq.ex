defmodule Hallux.Seq do

  defstruct [:__tree__]

  alias Hallux
  alias Hallux.Split
  alias Hallux.Seq.Views

  def new() do
    %__MODULE__{__tree__: Hallux.empty()}
  end
  def new(%Hallux.Empty{} = tree) do
    %__MODULE__{__tree__: tree}
  end
  def new(%Hallux.Single{} = tree) do
    %__MODULE__{__tree__: tree}
  end
  def new(%Hallux.Deep{} = tree) do
    %__MODULE__{__tree__: tree}
  end
  def new(enum, transform_fn \\ & &1) do
    tree = Enum.map(enum, transform_fn)
    |> Hallux.to_tree(zero(), &measure_fn/1, &reduce_fn/2)

    %__MODULE__{__tree__: tree}
  end

  def to_list(%__MODULE__{__tree__: tree}) do
    Hallux.to_list(tree)
  end

  def at(%__MODULE__{__tree__: tree} = seq, index)
    when is_integer(index)
    and index >= 0
  do
    if index >= size(seq) do
      nil
    else
      predicate = & &1 >= index + 1
      %Split{x: target} = Split.split_tree(predicate,
        zero(), tree, zero(), &measure_fn/1, &reduce_fn/2
      )
      target
    end
  end
  def at(%__MODULE__{} = seq, index)
    when is_integer(index)
    and index < 0
  do
    seq_size = size(seq)
    if abs(index) > seq_size do
      nil
    else
      index_ = seq_size + index
      at(seq, index_)
    end
  end

  def split_at(%__MODULE__{__tree__: tree} = seq, index)
    when is_integer(index)
    and index >= 0
  do
    if index >= size(seq) do
      :error
    else
      predicate = & &1 >= index + 1
      {left, right} = Split.split(tree, predicate, zero(), &measure_fn/1, &reduce_fn/2)
      {:ok, {new(left), new(right)}}
    end
  end
  def split_at(%__MODULE__{} = seq, index)
    when is_integer(index)
    and index < 0
  do
    seq_size = size(seq)
    if abs(index) > seq_size do
      :error
    else
      index_ = seq_size + index
      split_at(seq, index_)
    end
  end

  def size(%__MODULE__{__tree__: tree}) do
    Hallux.Measured.size(tree, zero(), &measure_fn/1, &reduce_fn/2)
  end

  def empty?(%__MODULE__{__tree__: tree}) do
    Hallux.empty?(tree)
  end

  def cons(%__MODULE__{__tree__: tree}, elem) do
    Hallux.cons(tree, elem, zero(), &measure_fn/1, &reduce_fn/2)
    |> new()
  end

  def snoc(%__MODULE__{__tree__: tree}, elem) do
    Hallux.snoc(tree, elem, zero(), &measure_fn/1, &reduce_fn/2)
    |> new()
  end

  def append(%__MODULE__{__tree__: tree1},
             %__MODULE__{__tree__: tree2}) do
    Hallux.append(tree1, tree2, zero(), &measure_fn/1, &reduce_fn/2)
    |> new()
  end

  def viewL(%__MODULE__{__tree__: tree}) do
    case Hallux.viewL(tree) do
      %Hallux.Views.NilL{} ->
        %Views.NilL{}
      %Hallux.Views.ConsL{hd: hd, tl: tl} ->
        %Views.ConsL{hd: hd, tl: new(tl)}
    end
  end

  def viewR(%__MODULE__{__tree__: tree}) do
    case Hallux.viewR(tree) do
      %Hallux.Views.NilR{} ->
        %Views.NilR{}
      %Hallux.Views.ConsR{hd: hd, tl: tl} ->
        %Views.ConsR{hd: hd, tl: new(tl)}
    end
  end

  defp measure_fn(_), do: 1
  defp reduce_fn(x, y), do: x + y
  defp zero(), do: 0

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(seq, opts) do
      concat([
        "#HalluxSeq<",
        to_doc(Hallux.to_list(seq.__tree__), opts),
        ">"
      ])
    end
  end

end
