# Hallux

![build status](https://travis-ci.org/thalesmg/hallux.svg?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/hallux.svg)](http://hex.pm/packages/hallux)
[![Hex.pm](https://img.shields.io/hexpm/dt/hallux.svg)](https://hex.pm/packages/hallux)
[![Hex.pm](https://img.shields.io/hexpm/dw/hallux.svg)](https://hex.pm/packages/hallux)

A [Finger Tree](http://www.staff.city.ac.uk/~ross/papers/FingerTree.html) implemenation for Elixir.

Currently, a random access structure
([`Hallux.Seq`](https://hexdocs.pm/hallux/Hallux.Seq.html)) and an interval map
([`Hallux.IntervalMap`](https://hexdocs.pm/hallux/Hallux.IntervalMap.html)) is available for
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

## `Hallux.OrderedMap`

An ordered sequence that is also a hashmap on values.

- Items consist of a value and an order key. Values are hashed.
- The sequence is always sorted by the order, new items are inserted
  at their order position.
- Values can be retrieved in O(log(n)) if addressed by order key.
- All keys to an item can be retrieved in O(m*log(n)), where m is the
  number of occurrences of that value. (Currently, hash collisions are
  not checked.)

### Examples

```elixir
iex(1)> om1 = Hallux.OrderedMap.new([b: 10, c: 20, b: 15, c: 7])
#HalluxOrderedMap<[b: 10, b: 15, c: 20, c: 7]>
iex(2)> om2 = Hallux.OrderedMap.insert(om1, :a, 50)
#HalluxOrderedMap<[a: 50, b: 10, b: 15, c: 20, c: 7]>
iex(3)> Hallux.OrderedMap.get(om2, :b)
#HalluxOrderedMap<[b: 10, b: 15]>
iex(4)> Hallux.OrderedMap.split(om2, :b)
{#HalluxOrderedMap<[a: 50]>, #HalluxOrderedMap<[b: 10, b: 15]>,
 #HalluxOrderedMap<[c: 20, c: 7]>}
```

## Installation

Add `hallux` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hallux, "~> 1.2.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc). Docs can
be found at [https://hexdocs.pm/hallux](https://hexdocs.pm/hallux).

## References

- http://www.staff.city.ac.uk/~ross/papers/FingerTree.html
- http://hackage.haskell.org/package/containers/docs/Data-Sequence.html
- http://hackage.haskell.org/package/fingertree/docs/Data-FingerTree.html
