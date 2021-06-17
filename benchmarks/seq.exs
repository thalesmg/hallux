alias Hallux.Seq

make_test_input_snoc = fn n ->
  1..n
  |> Enum.reduce(Seq.new(), &Seq.snoc(&2, &1))
end

make_test_input_cons = fn n ->
  1..n
  |> Enum.reduce(Seq.new(), &Seq.cons(&2, &1))
end

inputs = %{
  "tiny sequence cons" => make_test_input_cons.(1),
  "small sequence cons" => make_test_input_cons.(100),
  "medium sequence cons" => make_test_input_cons.(10_000),
  "tiny sequence snoc" => make_test_input_snoc.(1),
  "small sequence snoc" => make_test_input_snoc.(100),
  "medium sequence snoc" => make_test_input_snoc.(10_000)
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
