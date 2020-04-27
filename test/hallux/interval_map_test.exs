defmodule Hallux.IntervalMapTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Hallux.IntervalMap
  alias Hallux.Protocol.Valid

  import Hallux.Test.Generators

  describe "valid" do
    property "generator" do
      check all(im <- interval_map()) do
        assert Valid.valid?(im)
      end
    end

    property "insert" do
      check all(is <- list_of(interval())) do
        im = Enum.reduce(is, IntervalMap.new(), &IntervalMap.insert(&2, &1))
        assert Valid.valid?(im)
      end
    end

    property "disjoint intervals" do
      check all(xs <- disjoint_intervals()) do
        im =
          Enum.reduce(xs, IntervalMap.new(), fn {x, y}, acc ->
            IntervalMap.insert(acc, {x, y})
          end)

        assert Valid.valid?(im)

        for [x, y] <- xs do
          assert IntervalMap.interval_match(im, {x, y}) == [{{x, y}, nil}],
                 "disjoint union should return only one interval. \n tree: #{
                   inspect(im.t, pretty: true)
                 }\n tuple: #{inspect({x, y})}"

          assert IntervalMap.interval_search(im, {x, y}) == [{{x, y}, nil}],
                 "disjoint union should return own interval. \n tree: #{
                   inspect(im.t, pretty: true)
                 }\n tuple: #{inspect({x, y})}"
        end
      end
    end
  end
end
