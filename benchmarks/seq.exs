alias Hallux.Seq

make_test_input_snoc = fn n ->
  1..n
  |> Enum.reduce(Seq.new(), &Seq.snoc(&2, &1))
end

make_test_input_cons = fn n ->
  1..n
  |> Enum.reduce(Seq.new(), &Seq.cons(&2, &1))
end

cons_or_snoc = fn element, seq ->
  case :rand.uniform(2) do
    1 -> Seq.cons(seq, element)
    2 -> Seq.snoc(seq, element)
  end
end

make_test_input = fn n ->
  1..n
  |> Enum.reduce(Seq.new(), cons_or_snoc)
end

make_test_input_concat = fn n ->
  make_test_input.(n)
  |> Seq.concat(make_test_input_cons.(n))
  |> Seq.concat(make_test_input_snoc.(n))
end

inputs = %{
  "tiny sequence" => make_test_input.(1),
  "small sequence" => make_test_input.(100),
  "medium sequence" => make_test_input.(10_000),
  "tiny sequence cons" => make_test_input_cons.(1),
  "small sequence cons" => make_test_input_cons.(100),
  "medium sequence cons" => make_test_input_cons.(10_000),
  "tiny sequence snoc" => make_test_input_snoc.(1),
  "small sequence snoc" => make_test_input_snoc.(100),
  "medium sequence snoc" => make_test_input_snoc.(10_000),
  "tiny sequence concat" => make_test_input_concat.(1),
  "small sequence concat" => make_test_input_concat.(100),
  "medium sequence concat" => make_test_input_concat.(10_000),
}

Benchee.run(
  %{
    "cons" => fn seq -> Seq.cons(seq, 0) end,
    "snoc" => fn seq -> Seq.snoc(seq, 0) end,
    "view_l" => fn seq -> Seq.view_l(seq) end,
    "view_r" => fn seq -> Seq.view_r(seq) end,
    "concat" => fn seq -> Seq.concat(seq, seq) end,
  },
  inputs: inputs,
  unit_scaling: :none
)
