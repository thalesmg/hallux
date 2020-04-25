defmodule Hallux.Internal.Node do
  alias Hallux.Internal.Node.Node2
  alias Hallux.Internal.Node.Node3
  alias Hallux.Protocol.Measured
  alias Hallux.Protocol.Monoid

  def node2(a, b) do
    %Node2{
      size:
        Monoid.mappend(
          Measured.size(a),
          Measured.size(b)
        ),
      l: a,
      r: b
    }
  end

  def node3(a, b, c) do
    %Node3{
      size:
        Monoid.mappend(
          Measured.size(a),
          Monoid.mappend(
            Measured.size(b),
            Measured.size(c)
          )
        ),
      l: a,
      m: b,
      r: c
    }
  end
end
