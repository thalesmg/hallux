defprotocol Hallux.Protocol.Monoid do
  @type m :: term

  @spec mappend(m, m) :: m
  def mappend(a, a)

  @spec mempty(m) :: m
  def mempty(a)
end

defimpl Hallux.Protocol.Monoid, for: List do
  def mempty(_), do: []

  def mappend(l1, l2), do: l1 ++ l2
end
