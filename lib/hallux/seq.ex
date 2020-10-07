defmodule Hallux.Seq do
  defstruct [:t]

  @moduledoc """
  A representation of a sequence of values of type a, allowing access
  to the ends in constant time, and append and split in time
  logarithmic in the size of the smaller piece.
  (taken from [here](http://hackage.haskell.org/package/fingertree-0.1.4.2/docs/Data-FingerTree.html#t:FingerTree))

  Supports efficient random access like accessing the nth element.

  A sequence can be constructed using `Hallux.Seq.new/0`:

      iex> new()
      #HalluxSeq<[]>

  Elements can be inserted at the left end using `Hallux.Seq.cons/2`:

      iex> new(1..4) |> cons(0)
      #HalluxSeq<[0, 1, 2, 3, 4]>

  Or they can be inserted at the right end using `Hallux.Seq.snoc/2`:

      iex> new(1..4) |> snoc(0)
      #HalluxSeq<[1, 2, 3, 4, 0]>

  Accessing a single element is cheap:

      iex> new(0..10) |> Enum.at(5)
      5
  """

  alias Hallux.Internal.Elem
  alias Hallux.Internal.FingerTree
  alias Hallux.Internal.FingerTree.Empty
  alias Hallux.Protocol.Measured
  alias Hallux.Protocol.Monoid
  alias Hallux.Protocol.Reduce
  alias Hallux.Internal.Size

  @type value :: term
  @type t(value) :: %__MODULE__{t: FingerTree.t(Elem, value)}
  @type t :: t(term)

  @doc """
  `(O(1))`. Returns a new Seq.

  ## Examples

      iex> new()
      #HalluxSeq<[]>
  """
  @spec new() :: t
  def new(), do: %__MODULE__{t: %Empty{monoid: Monoid.mempty(%Size{})}}

  @doc """
  `(O(n))`. Creates a Seq from an enumerable.

  ## Examples

      iex> new([1, 2, 3], & &1 * 2)
      #HalluxSeq<[2, 4, 6]>
  """
  @spec new(Enum.t()) :: t
  def new(enum) do
    Enum.reduce(enum, new(), &snoc(&2, &1))
  end

  @doc """
  `(O(n))`. Creates a Seq from an enumerable via the transformation function.

  ## Examples

      iex> new([:b, :a, 3])
      #HalluxSeq<[:b, :a, 3]>
  """
  @spec new(Enum.t(), (term -> val)) :: t(val) when val: value
  def new(enum, transform_fn) do
    Enum.reduce(enum, new(), fn x, acc ->
      snoc(acc, transform_fn.(x))
    end)
  end

  @doc """
  `(O(1))`. Returns the number of elements in `seq`.

  ## Examples

      iex> size(new(1..3))
      3

      iex> size(new())
      0
  """
  @spec size(t) :: non_neg_integer
  def size(%__MODULE__{t: t}) do
    %Size{s: s} = Measured.size(t)
    s
  end

  @doc """
  `(O(1))`. Add an element to the left end of a sequence.

  ## Examples

      iex> cons(new(1..3), 0)
      #HalluxSeq<[0, 1, 2, 3]>
  """
  @spec cons(t(val), new_val) :: t(val | new_val) when val: value, new_val: value
  def cons(%__MODULE__{t: t}, a), do: %__MODULE__{t: FingerTree.cons(t, %Elem{e: a})}

  @doc """
  `(O(1))`. Add an element to the right end of a sequence.

  ## Examples

      iex> snoc(new(1..3), 4)
      #HalluxSeq<[1, 2, 3, 4]>
  """
  @spec snoc(t(val), new_val) :: t(val | new_val) when val: value, new_val: value
  def snoc(%__MODULE__{t: t}, a), do: %__MODULE__{t: FingerTree.snoc(t, %Elem{e: a})}

  @doc """
  `(O(log(min(i,n-i))))`. The first `i` elements of a sequence.

  If `i` is negative, `take(s, i)` yields the empty sequence.

  If the sequence contains fewer than `i` elements, the whole sequence
  is returned.

  ## Examples

      iex> take(new(1..10), 4)
      #HalluxSeq<[1, 2, 3, 4]>
  """
  @spec take(t(val), non_neg_integer) :: t(val) when val: value
  def take(%__MODULE__{t: t}, n),
    do: %__MODULE__{t: FingerTree.take_until(t, fn %Size{s: s} -> s > n end)}

  @doc """
  `(O(log(min(i,n-i))))`. Elements of a sequence after the first `i`.

   If `i` is negative, `drop(s, i)` yields the whole sequence.

   If the sequence contains fewer than `i` elements, the empty sequence
   is returned.

  ## Examples

      iex> drop(new(1..10), 4)
      #HalluxSeq<[5, 6, 7, 8, 9, 10]>
  """
  @spec drop(t(val), non_neg_integer) :: t(val) when val: value
  def drop(%__MODULE__{t: t}, n),
    do: %__MODULE__{t: FingerTree.drop_until(t, fn %Size{s: s} -> s > n end)}

  @doc """
  `(O(n))`. Right-associative fold of the sequence.

  Reduces `seq` from right to left using `acc` as initial value and
  `rfn` as the binary operator.

  ## Examples

      iex> reducer(new(1..10), [], fn x, acc -> [x | acc] end)
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  """
  @spec reducer(t(val), acc, (val, acc -> acc)) :: acc when val: value, acc: term
  def reducer(seq = %__MODULE__{}, acc, rfn), do: Reduce.reducer(seq, acc, rfn)

  @doc """
  `(O(n))`. Left-associative fold of the sequence.

  Reduces `seq` from left to right using `acc` as initial value and
  `rfn` as the binary operator.

  ## Examples

      iex> reducel(new(1..10), [], fn x, acc -> [x | acc] end)
      [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
  """
  @spec reducel(t(val), acc, (val, acc -> acc)) :: acc when val: value, acc: term
  def reducel(seq = %__MODULE__{}, acc, lfn), do: Reduce.reducel(seq, acc, lfn)

  @doc """
  `(O(1))`. Analyse the left end of a sequence.

  Returns nil if empty. Otherwise, returns a tuple with the leftmost
  element and a new sequence with that element removed.

  ## Examples

      iex> view_l(new())
      nil

      iex> {1, rest} = view_l(new(1..10))
      iex> rest
      #HalluxSeq<[2, 3, 4, 5, 6, 7, 8, 9, 10]>
  """
  @spec view_l(t(val)) :: nil | {val, t(val)} when val: value
  def view_l(%__MODULE__{t: t}) do
    with {%Elem{e: x}, rest} <- FingerTree.view_l(t) do
      {x, %__MODULE__{t: rest}}
    end
  end

  @doc """
  `(O(1))`. Analyse the right end of a sequence.

  Returns nil if empty. Otherwise, returns a tuple with the rightmost
  element and a new sequence with that element removed.

  ## Examples

      iex> view_r(new())
      nil

      iex> {rest, 10} = view_r(new(1..10))
      iex> rest
      #HalluxSeq<[1, 2, 3, 4, 5, 6, 7, 8, 9]>
  """
  @spec view_r(t(val)) :: nil | {val, t(val)} when val: value
  def view_r(%__MODULE__{t: t}) do
    with {rest, %Elem{e: x}} <- FingerTree.view_r(t) do
      {%__MODULE__{t: rest}, x}
    end
  end

  @doc """
  `(O(log(min(i,n-i))))`. Takes a slice from index `i` until index `j`
  of the sequence.

  ## Examples

      iex> slice(new(), 1..4)
      #HalluxSeq<[]>

      iex> slice(new(0..4), 0..10)
      #HalluxSeq<[0, 1, 2, 3, 4]>

      iex> slice(new(1..10), -5..-2)
      #HalluxSeq<[6, 7, 8, 9]>

      iex> slice(new(0..10), 4..7)
      #HalluxSeq<[4, 5, 6, 7]>
  """
  @spec slice(t, Range.t()) :: t
  def slice(seq = %__MODULE__{}, from..to) when is_integer(from) and is_integer(to) do
    size = size(seq)
    [from, to] = Enum.map([from, to], &normalize_index(size, &1))

    seq
    |> drop(from)
    |> take(to - from + 1)
  end

  @doc """
  `(O(log(min(n1,n2))))`. Concatenates two sequences.

  ## Examples

      iex> concat(new(), new(1..4))
      #HalluxSeq<[1, 2, 3, 4]>

      iex> concat(new(1..4), new())
      #HalluxSeq<[1, 2, 3, 4]>

      iex> concat(new(1..4), new(5..8))
      #HalluxSeq<[1, 2, 3, 4, 5, 6, 7, 8]>

      iex> concat(new(5..8), new(1..4))
      #HalluxSeq<[5, 6, 7, 8, 1, 2, 3, 4]>
  """
  @spec concat(t(val1), t(val2)) :: t(val1 | val2) when val1: value, val2: value
  def concat(%__MODULE__{t: t1}, %__MODULE__{t: t2}) do
    %__MODULE__{t: FingerTree.concat(t1, t2)}
  end

  @doc """
  `(O(log(min(i,n-i))))`. Split a squence at a given position.

  ## Examples

      iex> {left, right} = split_at(new(0..8), 6)
      iex> left
      #HalluxSeq<[0, 1, 2, 3, 4, 5]>
      iex> right
      #HalluxSeq<[6, 7, 8]>

  """
  @spec split_at(t(val), integer()) :: {t(val), t(val)} when val: value
  def split_at(%__MODULE__{t: t}, i) when is_integer(i) do
    p = fn %Size{s: s} -> s > i end
    {l, r} = FingerTree.split(t, p)
    {%__MODULE__{t: l}, %__MODULE__{t: r}}
  end

  defp normalize_index(size, i) do
    if i >= 0 do
      i
    else
      size + i
    end
  end

  defimpl Hallux.Protocol.Reduce do
    alias Hallux.Internal.Elem
    alias Hallux.Protocol.Reduce
    alias Hallux.Seq

    def reducer(%Seq{t: t}, acc, rfn) do
      Reduce.reducer(t, acc, fn %Elem{e: e}, acc -> rfn.(e, acc) end)
    end

    def reducel(%Seq{t: t}, acc, lfn) do
      Reduce.reducel(t, acc, fn %Elem{e: e}, acc -> lfn.(e, acc) end)
    end
  end

  defimpl Enumerable do
    alias Hallux.Internal.FingerTree
    alias Hallux.Internal.Size
    alias Hallux.Protocol.Measured
    alias Hallux.Protocol.Reduce
    alias Hallux.Seq

    def count(%Seq{t: t}), do: {:ok, Measured.size(t)}

    def member?(_, _), do: {:error, __MODULE__}

    def reduce(_seq, {:halt, acc}, _fun), do: {:halted, acc}
    def reduce(seq, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(seq, &1, fun)}

    def reduce(%Seq{t: t}, {:cont, acc}, fun) do
      case FingerTree.view_l(t) do
        nil -> {:done, acc}
        {%Elem{e: x}, rest} -> reduce(%Seq{t: rest}, fun.(x, acc), fun)
      end
    end

    def slice(seq = %Seq{t: t}) do
      %Size{s: size} = Measured.size(t)

      slicing_fun = fn start, len ->
        %Seq{t: t_} =
          seq
          |> Seq.drop(start)
          |> Seq.take(len)

        Reduce.reducer(t_, [], &[&1.e | &2])
      end

      {:ok, size, slicing_fun}
    end
  end

  defimpl Collectable do
    alias Hallux.Seq

    def into(original) do
      collector_fn = fn
        seq, {:cont, elem} -> Seq.snoc(seq, elem)
        seq, :done -> seq
        _seq, :halt -> :ok
      end

      {original, collector_fn}
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(seq, opts) do
      opts = %Inspect.Opts{opts | charlists: :as_lists}

      concat([
        "#HalluxSeq<",
        Inspect.List.inspect(Enum.to_list(seq), opts),
        ">"
      ])
    end
  end
end
