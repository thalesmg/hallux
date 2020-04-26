defprotocol Hallux.Protocol.Reduce do
  @type a :: term
  @type b :: term

  @spec reducer(Reduce.t(), (a, b -> b), b) :: b
  def reducer(fa, b, rfn)

  @spec reducel(Reduce.t(), (a, b -> b), b) :: b
  def reducel(fa, b, lfn)
end

defimpl Hallux.Protocol.Reduce, for: List do
  def reducer(ls, b, rfn), do: Enum.reduce(ls, b, rfn)

  def reducel(ls, b, lfn),
    do:
      ls
      |> Enum.reverse()
      |> Enum.reduce(b, lfn)
end
