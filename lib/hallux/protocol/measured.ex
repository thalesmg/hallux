defprotocol Hallux.Protocol.Measured do
  alias Hallux.Protocol.Monoid

  @spec size(m :: term) :: Monoid.t()
  def size(m)

  @spec monoid_type(m :: term) :: Monoid.t()
  def monoid_type(m)
end
