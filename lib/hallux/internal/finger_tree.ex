defmodule Hallux.Internal.FingerTree do
  alias Hallux.Internal.Digit.One
  alias Hallux.Internal.Digit.Two
  alias Hallux.Internal.Digit.Three
  alias Hallux.Internal.Digit.Four
  alias Hallux.Internal.Node.Node3
  alias Hallux.Internal.FingerTree.Empty
  alias Hallux.Internal.FingerTree.Single
  alias Hallux.Internal.FingerTree.Deep
  alias Hallux.Protocol.Measured
  alias Hallux.Protocol.Monoid

  def cons(%Empty{monoid: m}, x),
    do: %Single{monoid: m, x: x}

  def cons(%Single{monoid: m, x: b}, a),
    do:
      deep(
        %One{a: a},
        %Empty{monoid: m},
        %One{a: b}
      )

  def cons(
        %Deep{
          monoid: mo,
          size: s,
          l: %Four{a: b, b: c, c: d, d: e},
          m: m,
          r: sf
        },
        a
      ),
      do: %Deep{
        monoid: mo,
        size: Monoid.mappend(Measured.size(a), s),
        l: %Two{a: a, b: b},
        m: cons(m, node3(c, d, e)),
        r: sf
      }

  def cons(
        %Deep{
          monoid: mo,
          size: s,
          l: %Three{a: b, b: c, c: d},
          m: m,
          r: sf
        },
        a
      ),
      do: %Deep{
        monoid: mo,
        size: Monoid.mappend(Measured.size(a), s),
        l: %Four{a: a, b: b, c: c, d: d},
        m: m,
        r: sf
      }

  def cons(
        %Deep{
          monoid: mo,
          size: s,
          l: %Two{a: b, b: c},
          m: m,
          r: sf
        },
        a
      ),
      do: %Deep{
        monoid: mo,
        size: Monoid.mappend(Measured.size(a), s),
        l: %Three{a: a, b: b, c: c},
        m: m,
        r: sf
      }

  def cons(
        %Deep{
          monoid: mo,
          size: s,
          l: %One{a: b},
          m: m,
          r: sf
        },
        a
      ),
      do: %Deep{
        monoid: mo,
        size: Monoid.mappend(Measured.size(a), s),
        l: %Two{a: a, b: b},
        m: m,
        r: sf
      }

  def snoc(%Empty{monoid: m}, x),
    do: %Single{monoid: m, x: x}

  def snoc(%Single{monoid: m, x: a}, b),
    do:
      deep(
        %One{a: a},
        %Empty{monoid: m},
        %One{a: b}
      )

  def snoc(
        %Deep{
          monoid: mo,
          size: s,
          l: pr,
          m: m,
          r: %Four{a: a, b: b, c: c, d: d}
        },
        e
      ),
      do: %Deep{
        monoid: mo,
        size: Monoid.mappend(Measured.size(e), s),
        l: pr,
        m: snoc(m, node3(a, b, c)),
        r: %Two{a: d, b: e}
      }

  def snoc(
        %Deep{
          monoid: mo,
          size: s,
          l: pr,
          m: m,
          r: %Three{a: a, b: b, c: c}
        },
        d
      ),
      do: %Deep{
        monoid: mo,
        size: Monoid.mappend(Measured.size(d), s),
        l: pr,
        m: m,
        r: %Four{a: a, b: b, c: c, d: d}
      }

  def snoc(
        %Deep{
          monoid: mo,
          size: s,
          l: pr,
          m: m,
          r: %Two{a: a, b: b}
        },
        c
      ),
      do: %Deep{
        monoid: mo,
        size: Monoid.mappend(Measured.size(c), s),
        l: pr,
        m: m,
        r: %Three{a: a, b: b, c: c}
      }

  def snoc(
        %Deep{
          monoid: mo,
          size: s,
          l: pr,
          m: m,
          r: %One{a: a}
        },
        b
      ),
      do: %Deep{
        monoid: mo,
        size: Monoid.mappend(Measured.size(b), s),
        l: pr,
        m: m,
        r: %Two{a: a, b: b}
      }

  defp deep(d1, t, d2),
    do: %Deep{
      monoid: t.monoid,
      size:
        Monoid.mappend(
          Measured.size(d1),
          Monoid.mappend(
            Measured.size(t),
            Measured.size(d2)
          )
        ),
      l: d1,
      m: t,
      r: d2
    }

  defp node2(a, b) do
    %Node2{
      l: a,
      r: b,
      size:
        Monoid.mappend(
          Measured.size(a),
          Measured.size(b)
        )
    }
  end

  defp node3(a, b, c) do
    %Node3{
      l: a,
      m: b,
      r: c,
      size:
        Monoid.mappend(
          Measured.size(a),
          Monoid.mappend(
            Measured.size(b),
            Measured.size(c)
          )
        )
    }
  end
end
