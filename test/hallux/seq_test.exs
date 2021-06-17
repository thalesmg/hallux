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

    property "cons . view_l = id" do
      check all(
              s <- seq(),
              item <- term()
            ) do
        {item_, s_} = Seq.view_l(Seq.cons(s, item))
        assert_equal(s, s_)
        assert item == item_
      end
    end
  end

  property "snoc . view_r = id" do
    check all(
            s <- seq(),
            item <- term()
          ) do
      {s_, item_} = Seq.view_r(Seq.snoc(s, item))
      assert_equal(s, s_)
      assert item == item_
    end
  end

  property "concat . to_list = to_list . ++" do
    check all(
            s1 <- seq(),
            s2 <- seq()
          ) do
      assert Enum.to_list(Seq.concat(s1, s2)) == Enum.to_list(s1) ++ Enum.to_list(s2)
    end
  end

  defp assert_equal(s1 = %Seq{}, s2 = %Seq{}) do
    assert Enum.to_list(s1) == Enum.to_list(s2)
  end
end
