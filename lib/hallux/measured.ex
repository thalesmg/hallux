defprotocol Hallux.Measured do
  def size(measurable, zero, measure_fn, reduce_fn)
end

defimpl Hallux.Measured, for: List do
  def size(list, z, measure_fn, reduce_fn)
    when is_function(measure_fn, 1)
    and is_function(reduce_fn, 2),
    do: Stream.map(list, measure_fn)
        |> Enum.reduce(z, reduce_fn)
end
