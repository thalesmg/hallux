alias Hallux.IntervalMap

make_low_high_pair = fn n ->
    start = :rand.uniform(n)
    length = :rand.uniform(n)
    {start, start + length}
  end

make_test_input = fn n ->
    im = for _ <- 1..n do
      {make_low_high_pair.(n), nil}
    end
    |> Enum.into(IntervalMap.new())
    {im, n}
  end

inputs = %{
  "tiny interval map" => make_test_input.(1),
  "small interval map" => make_test_input.(100),
  "medium interval map" => make_test_input.(10_000),
}

Benchee.run(
  %{
    "insert" => fn {interval_map, n} -> IntervalMap.insert(interval_map, make_low_high_pair.(n)) end,
    "interval_search" => fn {interval_map, n} -> IntervalMap.interval_search(interval_map, make_low_high_pair.(n)) end,
    "interval_match" => fn {interval_map, n} -> IntervalMap.interval_match(interval_map, make_low_high_pair.(n)) end
  },
  inputs: inputs,
  unit_scaling: :none
)
