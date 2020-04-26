# Hallux ![build status](https://travis-ci.org/thalesmg/hallux.svg?branch=master)

A [Finger Tree](http://www.staff.city.ac.uk/~ross/papers/FingerTree.html) implemenation for Elixir.

Currently, only a random access structure (`Hallux.Seq`) is available for use. It allows appending to the front and to the back efficiently.

## Examples

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
