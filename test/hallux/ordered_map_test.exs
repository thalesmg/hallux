defmodule Hallux.OrderedMapTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Hallux.Protocol.Valid
  alias Hallux.OrderedMap

  import Hallux.Test.Generators

  doctest OrderedMap, import: true

  describe "valid" do
    property "generator" do
      check all(om <- ordered_map()) do
        assert Valid.valid?(om)
      end
    end

    property "insert" do
      check all(
              keys <- list_of(term()),
              values <- list_of(term(), length: length(keys))
            ) do
        om =
          keys
          |> Enum.zip(values)
          |> Enum.reduce(OrderedMap.new(), fn {key, value}, om ->
            OrderedMap.insert(om, key, value)
          end)

        assert Valid.valid?(om)
      end
    end

    property "split" do
      check all(
              middle <- term(),
              om <- ordered_map()
            ) do
        {om1, om2, om3} = OrderedMap.split(om, middle)
        assert Valid.valid?(om1)
        assert Valid.valid?(om2)
        assert Valid.valid?(om3)
      end
    end

    property "filter_value" do
      check all(
              middle <- term(),
              om <- ordered_map()
            ) do
        om_filter = OrderedMap.filter_value(om, middle)
        assert Valid.valid?(om_filter)
      end
    end
  end

  describe "split" do
    property "all left keys are smaller" do
      check all(
              middle <- term(),
              om <- ordered_map()
            ) do
        {om1, _om2, _om3} = OrderedMap.split(om, middle)

        assert(
          om1
          |> OrderedMap.keys()
          |> Enum.all?(&(&1 < middle))
        )
      end
    end

    property "all middle keys are equal" do
      check all(
              middle <- term(),
              om <- ordered_map()
            ) do
        {_om1, om2, _om3} = OrderedMap.split(om, middle)

        assert(
          om2
          |> OrderedMap.keys()
          |> Enum.all?(&(&1 == middle))
        )
      end
    end

    property "all right keys are greater" do
      check all(
              middle <- term(),
              om <- ordered_map()
            ) do
        {_om1, _om2, om3} = OrderedMap.split(om, middle)

        assert(
          om3
          |> OrderedMap.keys()
          |> Enum.all?(&(&1 > middle))
        )
      end
    end
  end

  describe "filter_value" do
    property "all filtered values are equal to the filter" do
      check all(
              value <- integer(1..5),
              om <- ordered_map(string(:alphanumeric), integer(1..5))
            ) do
        assert(
          om
          |> OrderedMap.filter_value(value)
          |> OrderedMap.values()
          |> Enum.all?(&(&1 == value))
        )
      end
    end
  end
end
