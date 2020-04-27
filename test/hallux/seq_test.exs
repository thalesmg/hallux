defmodule Hallux.SeqTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Hallux.Protocol.Valid
  alias Hallux.Seq

  import Hallux.Test.Generators

  doctest Seq, import: true

  property "concat . splitAt = id" do
    check all(
            s <- seq(),
            n = Seq.size(s),
            i <- member_of(0..n)
          ) do
      {l, r} = Seq.split_at(s, i)
      assert_equal(Seq.concat(l, r), s)
    end
  end

  describe "valid" do
    property "generator" do
      check all(s <- seq()) do
        assert Valid.valid?(s)
      end
    end

    property "cons" do
      check all(xs <- list_of(term())) do
        seq = Enum.reduce(xs, Seq.new(), &Seq.cons(&2, &1))
        assert Valid.valid?(seq)
      end
    end

    property "snoc" do
      check all(xs <- list_of(term())) do
        seq = Enum.reduce(xs, Seq.new(), &Seq.snoc(&2, &1))
        assert Valid.valid?(seq)
      end
    end
  end

  defp assert_equal(s1 = %Seq{}, s2 = %Seq{}) do
    assert Enum.to_list(s1) == Enum.to_list(s2)
  end
end
