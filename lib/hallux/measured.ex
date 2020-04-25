defprotocol Hallux.Measured do
  @fallback_to_any true
  def size(measurable, zero, measure_fn, reduce_fn)
end

defimpl Hallux.Measured, for: List do
  alias Hallux.Measured

  def size(list, z, measure_fn, reduce_fn)
      when is_function(measure_fn, 1) and is_function(reduce_fn, 2),
      do:
        Stream.map(list, &Measured.size(&1, z, measure_fn, reduce_fn))
        |> Enum.reduce(z, reduce_fn)
end

defimpl Hallux.Measured, for: Any do
  def size(x, zero, measure_fn, reduce_fn) do
    reduce_fn.(measure_fn.(x), zero)
  end
end
