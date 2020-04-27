# Hallux ![build status](https://travis-ci.org/thalesmg/hallux.svg?branch=master)

A [Finger Tree](http://www.staff.city.ac.uk/~ross/papers/FingerTree.html) implemenation for Elixir.

Currently, a random access structure
([`Hallux.Seq`](lib/hallux/seq.ex)) and an interval map
([`Hallux.IntervalMap`](lib/hallux/interval_map.ex)) is available for
use.

## `Hallux.Seq`

Supports efficient insertion from both left and right ends and random
access.

### Examples

```elixir
iex> Hallux.Seq.new
#HalluxSeq<[]>
iex> seq = 1..10 |> Hallux.Seq.new
#HalluxSeq<[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]>
iex> Hallux.Seq.cons(seq, 0)
#HalluxSeq<[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]>
iex> Hallux.Seq.snoc(seq, 11)
#HalluxSeq<[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]>
iex> Enum.at(seq, 5)
6
iex> Enum.at(seq, 0)
1
```

## `Hallux.IntervalMap`

A map of closed intervals can be used to find an interval that
overlaps with a given interval in O(log(n)), and all m of them in
O(m log(n/m)) time.

### Examples

```elixir
iex(1)> im = Enum.into([{{1, 2}, :a}, {{4, 10}, :b}, {{9, 15}, :c}], Hallux.IntervalMap.new())
#HalluxIMap<[{{1, 2}, :a}, {{4, 10}, :b}, {{9, 15}, :c}]>
iex(2)> Hallux.IntervalMap.interval_
interval_match/2     interval_search/2
iex(2)> Hallux.IntervalMap.interval_match(im, {8, 9})
[{{4, 10}, :b}, {{9, 15}, :c}]
```

## Installation

Add `hallux` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hallux, "~> 1.0.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc). Docs can
be found at [https://hexdocs.pm/hallux](https://hexdocs.pm/hallux).

## References

- http://www.staff.city.ac.uk/~ross/papers/FingerTree.html
- http://hackage.haskell.org/package/containers/docs/Data-Sequence.html
- http://hackage.haskell.org/package/fingertree/docs/Data-FingerTree.html
