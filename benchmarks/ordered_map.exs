alias Hallux.OrderedMap

make_test_list = fn n ->
  for i <- 1..n do
    {i, Enum.random([:hi, "world", 23])}
  end
  |> Enum.to_list()
end

make_test_ordered_map = fn n ->
  make_test_list.(n)
  |> OrderedMap.new()
end

make_test_input = fn n ->
  map = make_test_ordered_map.(n)
  inserted = 1..5
    |> Enum.map(&{round(div(&1 * n, 5)), :inserted})
    |> Enum.into(map)
  {n, make_test_list.(n), map, inserted}
end

inputs = %{
  "tiny ordered map" => make_test_input.(1),
  "small ordered map" => make_test_input.(100),
  "medium ordered map" => make_test_input.(10_000),
}

Benchee.run(
  %{
    "new" => fn {_n, list, _map, _inserted} -> OrderedMap.new(list) end,
    "split" => fn {n, _list, map, _inserted} -> OrderedMap.split(map, div(n, 2)) end,
    "insert" => fn {n, _list, map, _inserted} -> OrderedMap.insert(map, div(n, 2), "inserted") end,
    "filter_value" => fn {_n, _list, _map, inserted} -> OrderedMap.filter_value(inserted, :inserted) end,
  },
  inputs: inputs,
  unit_scaling: :none
)
