defprotocol Hallux.Protocol.Valid do
  @fallback_to_any true

  @spec valid?(term) :: bool
  def valid?(x)
end

defimpl Hallux.Protocol.Valid, for: Any do
  def valid?(_), do: true
end

defimpl Hallux.Protocol.Valid, for: Hallux.Internal.FingerTree.Empty do
  def valid?(_), do: true
end

defimpl Hallux.Protocol.Valid, for: Hallux.Internal.FingerTree.Single do
  alias Hallux.Internal.FingerTree.Single
  alias Hallux.Protocol.Valid

  def valid?(%Single{x: x}), do: Valid.valid?(x)
end

defimpl Hallux.Protocol.Valid, for: Hallux.Internal.FingerTree.Deep do
  alias Hallux.Internal.FingerTree.Deep
  alias Hallux.Protocol.Measured
  alias Hallux.Protocol.Monoid
  alias Hallux.Protocol.Valid

  def valid?(%Deep{size: s, l: pr, m: m, r: sf}) do
    s ==
      Measured.size(
        Monoid.mappend(
          Measured.size(pr),
          Monoid.mappend(
            Measured.size(m),
            Measured.size(sf)
          )
        )
      ) && Valid.valid?(pr) && Valid.valid?(m) && Valid.valid?(sf)
  end
end

defimpl Hallux.Protocol.Valid, for: Hallux.Internal.Node.Node2 do
  alias Hallux.Internal.Node.Node2
  alias Hallux.Protocol.Measured
  alias Hallux.Protocol.Monoid
  alias Hallux.Protocol.Valid

  def valid?(node = %Node2{l: l, r: r}) do
    Measured.size(node) ==
      Measured.size(
        Monoid.mappend(
          Measured.size(l),
          Measured.size(r)
        )
      ) && Enum.all?([l, r], &Valid.valid?/1)
  end
end

defimpl Hallux.Protocol.Valid, for: Hallux.Internal.Node.Node3 do
  alias Hallux.Internal.Node.Node3
  alias Hallux.Protocol.Measured
  alias Hallux.Protocol.Monoid
  alias Hallux.Protocol.Valid

  def valid?(node = %Node3{l: l, m: m, r: r}) do
    Measured.size(node) ==
      Measured.size(
        Monoid.mappend(
          Measured.size(l),
          Monoid.mappend(
            Measured.size(m),
            Measured.size(r)
          )
        )
      ) && Enum.all?([l, m, r], &Valid.valid?/1)
  end
end

defimpl Hallux.Protocol.Valid, for: Hallux.Internal.Digit.One do
  alias Hallux.Internal.Digit.One
  alias Hallux.Protocol.Valid

  def valid?(%One{a: a}) do
    Valid.valid?(a)
  end
end

defimpl Hallux.Protocol.Valid, for: Hallux.Internal.Digit.Two do
  alias Hallux.Internal.Digit.Two
  alias Hallux.Protocol.Valid

  def valid?(%Two{a: a, b: b}) do
    Enum.all?([a, b], &Valid.valid?/1)
  end
end

defimpl Hallux.Protocol.Valid, for: Hallux.Internal.Digit.Three do
  alias Hallux.Internal.Digit.Three
  alias Hallux.Protocol.Valid

  def valid?(%Three{a: a, b: b, c: c}) do
    Enum.all?([a, b, c], &Valid.valid?/1)
  end
end

defimpl Hallux.Protocol.Valid, for: Hallux.Internal.Digit.Four do
  alias Hallux.Internal.Digit.Four
  alias Hallux.Protocol.Valid

  def valid?(%Four{a: a, b: b, c: c, d: d}) do
    Enum.all?([a, b, c, d], &Valid.valid?/1)
  end
end
