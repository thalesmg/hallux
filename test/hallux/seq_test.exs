defmodule Hallux.SeqTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Hallux.Seq

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

  defp assert_equal(s1 = %Seq{}, s2 = %Seq{}) do
    assert Enum.to_list(s1) == Enum.to_list(s2)
  end

  defp seq(generator \\ term()) do
    gen all(xs <- list_of(generator)) do
      Seq.new(xs)
    end
  end
end
