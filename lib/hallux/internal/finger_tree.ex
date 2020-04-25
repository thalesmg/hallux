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

  defp append0(%Empty{}, r), do: r
  defp append0(l, %Empty{}), do: l
  defp append0(%Single{x: x}, r), do: cons(r, x)
  defp append0(l, %Single{x: x}), do: snoc(l, x)

  defp append0(
         %Deep{
           monoid: mo,
           size: s1,
           l: pr1,
           m: m1,
           r: sf1
         },
         %Deep{
           monoid: mo,
           size: s2,
           l: pr2,
           m: m2,
           r: sf2
         }
       ),
       do: %Deep{
         monoid: mo,
         size: Monoid.mappend(s1, s2),
         l: pr1,
         m: add_digits0(m1, sf1, pr2, m2),
         r: sf2
       }

  # One
  defp add_digits0(m1, %One{a: a}, %One{a: b}, m2),
    do: append1(m1, node2(a, b), m2)

  defp add_digits0(m1, %One{a: a}, %Two{a: b, b: c}, m2),
    do: append1(m1, node3(a, b, c), m2)

  defp add_digits0(m1, %One{a: a}, %Three{a: b, b: c, c: d}, m2),
    do: append2(m1, node2(a, b), node2(c, d), m2)

  defp add_digits0(m1, %One{a: a}, %Four{a: b, b: c, c: d, d: e}, m2),
    do: append2(m1, node3(a, b, c), node2(d, e), m2)


  # Two
  defp add_digits0(m1, %Two{a: a, b: b}, %One{a: c}, m2),
    do: append1(m1, node3(a, b, c), m2)

  defp add_digits0(m1, %Two{a: a, b: b}, %Two{a: c, b: d}, m2),
    do: append2(m1, node2(a, b), node2(c, d), m2)

  defp add_digits0(m1, %Two{a: a, b: b}, %Three{a: c, b: d, c: e}, m2),
    do: append2(m1, node3(a, b, c), node2(d, e), m2)

  defp add_digits0(m1, %Two{a: a, b: b}, %Four{a: c, b: d, c: e, d: f}, m2),
    do: append2(m1, node3(a, b, c), node3(d, e, f), m2)


  # Three
  defp add_digits0(m1, %Three{a: a, b: b, c: c}, %One{a: d}, m2),
    do: append2(m1, node2(a, b), node2(c, d), m2)

  defp add_digits0(m1, %Three{a: a, b: b, c: c}, %Two{a: d, b: e}, m2),
    do: append2(m1, node3(a, b, c), node2(d, e), m2)

  defp add_digits0(m1, %Three{a: a, b: b, c: c}, %Three{a: d, b: e, c: f}, m2),
    do: append2(m1, node3(a, b, c), node3(d, e, f), m2)

  defp add_digits0(m1, %Three{a: a, b: b, c: c}, %Four{a: d, b: e, c: f, d: h}, m2),
    do: append3(m1, node3(a, b, c), node2(d, e), node2(f, g), m2)


  # Four
  defp add_digits0(m1, %Four{a: a, b: b, c: c, d: d}, %One{a: e}, m2),
    do: append2(m1, node3(a, b, c), node2(d, e), m2)

  defp add_digits0(m1, %Four{a: a, b: b, c: c, d: d}, %Two{a: e, b: f}, m2),
    do: append2(m1, node3(a, b, c), node3(d, e, f), m2)

  defp add_digits0(m1, %Four{a: a, b: b, c: c, d: d}, %Three{a: e, b: f, c: g}, m2),
    do: append3(m1, node3(a, b, c), node2(d, e), node2(f, g), m2)

  defp add_digits0(m1, %Four{a: a, b: b, c: c, d: d}, %Four{a: e, b: f, c: g, d: h}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node2(g, h), m2)


  defp append1(%Empty{}, a, xs),
    do: cons(xs, a)

  defp append1(xs, a, %Empty{}),
    do: snoc(xs, a)

  defp append1(%Single{x: x}, a, xs),
    do: cons(cons(xs, a), x)

  defp append1(xs, a, %Single{x: x}),
    do: snoc(snoc(xs, a), x)

  defp append1(%Deep{
        monoid: mo,
        size: s1,
        l: pr1,
        m: m1,
        r: sf1
               }, a,
    %Deep{
      monoid: mo,
      size: s2,
      l: pr2,
      m: m2,
      r: sf2
    }),
    do: %Deep{
          monoid: mo,
          size: Monoid.mappend(
            s1,
            Monoid.mappend(
              Measured.size(a),
              s2
            )
          ),
          l: pr1,
          m: add_digits1(m1, sf1, a, pr2, m2),
          r: sf2
    }


  # One
  defp add_digits1(m1, %One{a: a}, b, %One{a: c}, m2),
    do: append1(m1, node3(a, b, c), m2)

  defp add_digits1(m1, %One{a: a}, b, %Two{a: c, b: d}, m2),
    do: append2(m1, node2(a, b), node2(c, d), m2)

  defp add_digits1(m1, %One{a: a}, b, %Three{a: c, b: d, c: e}, m2),
    do: append2(m1, node3(a, b, c), node2(d, e), m2)

  defp add_digits1(m1, %One{a: a}, b, %Four{a: c, b: d, c: e, d: f}, m2),
    do: append2(m1, node3(a, b, c), node3(d, e, f), m2)


  # Two
  defp add_digits1(m1, %Two{a: a, b: b}, c, %One{a: d}, m2),
    do: append2(m1, node2(a, b), node2(c, d), m2)

  defp add_digits1(m1, %Two{a: a, b: b}, c, %Two{a: d, b: e}, m2),
    do: append2(m1, node3(a, b, c), node2(d, e), m2)

  defp add_digits1(m1, %Two{a: a, b: b}, c, %Three{a: d, b: e, c: f}, m2),
    do: append2(m1, node3(a, b, c), node3(d, e, f), m2)

  defp add_digits1(m1, %Two{a: a, b: b}, c, %Four{a: d, b: e, c: f, d: g}, m2),
    do: append3(m1, node3(a, b, c), node2(d, e), node2(f, g), m2)


  # Three
  defp add_digits1(m1, %Three{a: a, b: b, c: c}, d, %One{a: e}, m2),
    do: append2(m1, node3(a, b, c), node2(d, e), m2)

  defp add_digits1(m1, %Three{a: a, b: b, c: c}, d, %Two{a: e, b: f}, m2),
    do: append2(m1, node3(a, b, c), node3(d, e, f), m2)

  defp add_digits1(m1, %Three{a: a, b: b, c: c}, d, %Three{a: e, b: f, c: g}, m2),
    do: append3(m1, node3(a, b, c), node2(d, e), node2(f, g), m2)

  defp add_digits1(m1, %Three{a: a, b: b, c: c}, d, %Four{a: e, b: f, c: g, d: h}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node2(g, h), m2)


  # Four
  defp add_digits1(m1, %Four{a: a, b: b, c: c, d: d}, e, %One{a: f}, m2),
    do: append2(m1, node3(a, b, c), node3(d, e, f), m2)

  defp add_digits1(m1, %Four{a: a, b: b, c: c, d: d}, e, %Two{a: f, b: g}, m2),
    do: append3(m1, node3(a, b, c), node2(d, e), node2(f, g), m2)

  defp add_digits1(m1, %Four{a: a, b: b, c: c, d: d}, e, %Three{a: f, b: g, c: h}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node2(g, h), m2)

  defp add_digits1(m1, %Four{a: a, b: b, c: c, d: d}, e, %Three{a: f, b: g, c: h, d: i}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node3(g, h, i), m2)



  defp append2(%Empty{}, a, b, xs),
    do: cons(cons(xs, b), a)

  defp append2(xs, a, b, %Empty{}),
    do: snoc(snoc(xs, a), b)

  defp append2(%Single{x: x}, a, b, xs),
    do: cons(cons(cons(xs, b), a), x)

  defp append2(xs, a, b, %Single{x: x}),
    do: snoc(snoc(snoc(xs, a), b), x)

  defp append2(%Deep{
        monoid: mo,
        size: s1,
        l: pr1,
        m: m1,
        r: sf1
               },
    a, b,
    %Deep{
        monoid: mo,
        size: s2,
        l: pr2,
        m: m2,
        r: sf2
               }),
    do: %Deep{
          monoid: mo,
          size: Monoid.mappend(
            s1,
            Monoid.mappend(
              Measured.size(a),
              Monoid.mappend(
                Measured.size(b),
                s2
              )
            )
          ),
          l: pr1,
          m: add_digits2(m1, sf1, a, b, pr2, m2),
          r: sf2
    }



  # One
  defp add_digits2(m1, %One{a: a}, b, c, %One{a: d}, m2),
    do: append2(m1, node2(a, b), node2(c, d), m2)

  defp add_digits2(m1, %One{a: a}, b, c, %Two{a: d, b: e}, m2),
    do: append2(m1, node3(a, b, c), node2(d, e), m2)

  defp add_digits2(m1, %One{a: a}, b, c, %Three{a: d, b: e, c: f}, m2),
    do: append2(m1, node3(a, b, c), node3(d, e, f), m2)

  defp add_digits2(m1, %One{a: a}, b, c, %Four{a: d, b: e, c: f, d: g}, m2),
    do: append3(m1, node3(a, b, c), node2(d, e), node2(f, g), m2)


  # Two
  defp add_digits2(m1, %Two{a: a, b: b}, c, d, %One{a: e}, m2),
    do: append2(m1, node3(a, b, c), node2(d, e), m2)

  defp add_digits2(m1, %Two{a: a, b: b}, c, d, %Two{a: e, b: f}, m2),
    do: append2(m1, node3(a, b, c), node3(d, e, f), m2)

  defp add_digits2(m1, %Two{a: a, b: b}, c, d, %Three{a: e, b: f, c: g}, m2),
    do: append3(m1, node3(a, b, c), node2(d, e), node2(f, g), m2)

  defp add_digits2(m1, %Two{a: a, b: b}, c, d, %Four{a: e, b: f, c: g, d: h}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node2(g, h), m2)


  # Three
  defp add_digits2(m1, %Three{a: a, b: b, c: c}, d, e, %One{a: f}, m2),
    do: append2(m1, node3(a, b, c), node3(d, e, f), m2)

  defp add_digits2(m1, %Three{a: a, b: b, c: c}, d, e, %Two{a: f, b: g}, m2),
    do: append3(m1, node3(a, b, c), node2(d, e), node2(f, g), m2)

  defp add_digits2(m1, %Three{a: a, b: b, c: c}, d, e, %Three{a: f, b: g, c: h}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node2(g, h), m2)

  defp add_digits2(m1, %Three{a: a, b: b, c: c}, d, e, %Four{a: f, b: g, c: h, d: i}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node3(g, h, i), m2)


  # Four
  defp add_digits2(m1, %Four{a: a, b: b, c: c, d: d}, e, f, %One{a: g}, m2),
    do: append3(m1, node3(a, b, c), node2(d, e), node2(f, g), m2)

  defp add_digits2(m1, %Four{a: a, b: b, c: c, d: d}, e, f, %Two{a: g, b: h}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node2(g, h), m2)

  defp add_digits2(m1, %Four{a: a, b: b, c: c, d: d}, e, f, %Three{a: g, b: h, c: i}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node3(g, h, i), m2)

  defp add_digits2(m1, %Four{a: a, b: b, c: c, d: d}, e, f, %Four{a: g, b: h, c: i, d: j}, m2),
    do: append4(m1, node3(a, b, c), node3(d, e, f), node2(g, h), node2(i, j), m2)


  defp append3(%Empty{}, a, b, c, xs),
    do: xs |> cons(c) |> cons(b) |> cons(a)

  defp append3(xs, a, b, c, %Empty{}),
    do: xs |> snoc(a) |> snoc(b) |> snoc(c)

  defp append3(%Single{x: x}, a, b, c, xs),
    do: xs |> cons(c) |> cons(b) |> cons(a) |> cons(x)

  defp append3(xs, a, b, c, %Single{x: x}),
    do: xs |> snoc(a) |> snoc(b) |> snoc(c) |> snoc(x)

  defp append3(%Deep{
        monoid: mo,
        size: s1,
        l: pr1,
        m: m1,
        r: sf1
               },
    a, b, c,
    %Deep{
        monoid: mo,
        size: s2,
        l: pr2,
        m: m2,
        r: sf2
               }
    ),
    do: %Deep{
          monoid: mo,
          size: Monoid.mappend(
            s1,
            Monoid.mappend(
              Measured.size(a),
              Monoid.mappend(
                Measured.size(b),
                Monoid.mappend(
                  Measured.size(c),
                  s2
                )
              )
            )
          ),
          l: pr1,
          m: add_digits3(m1, sf1, a, b, c, pr2, m2),
          r: sf2
    }


  # One
  defp add_digits3(m1, %One{a: a}, b, c, d, %One{a: e}, m2),
    do: append2(m1, node3(a, b, c), node2(d, e), m2)

  defp add_digits3(m1, %One{a: a}, b, c, d, %Two{a: e, b: f}, m2),
    do: append2(m1, node3(a, b, c), node3(d, e, f), m2)

  defp add_digits3(m1, %One{a: a}, b, c, d, %Three{a: e, b: f, c: g}, m2),
    do: append3(m1, node3(a, b, c), node2(d, e), node2(f, g), m2)

  defp add_digits3(m1, %One{a: a}, b, c, d, %Four{a: e, b: f, c: g, d: h}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node2(g, h), m2)


  # Two
  defp add_digits3(m1, %Two{a: a, b: b}, c, d, e, %One{a: f}, m2),
    do: append2(m1, node3(a, b, c), node3(d, e, f), m2)

  defp add_digits3(m1, %Two{a: a, b: b}, c, d, e, %Two{a: f, b: g}, m2),
    do: append3(m1, node3(a, b, c), node2(d, e), node2(f, g), m2)

  defp add_digits3(m1, %Two{a: a, b: b}, c, d, e, %Three{a: f, b: g, c: h}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node2(g, h), m2)

  defp add_digits3(m1, %Two{a: a, b: b}, c, d, e, %Four{a: f, b: g, c: h, d: i}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node3(g, h, i), m2)


  # Three
  defp add_digits3(m1, %Three{a: a, b: b, c: c}, d, e, f, %One{a: g}, m2),
    do: append3(m1, node3(a, b, c), node2(d, e), node2(f, g), m2)

  defp add_digits3(m1, %Three{a: a, b: b, c: c}, d, e, f, %Two{a: g, b: h}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node2(g, h), m2)

  defp add_digits3(m1, %Three{a: a, b: b, c: c}, d, e, f, %Three{a: g, b: h, c: i}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node3(g, h, i), m2)

  defp add_digits3(m1, %Three{a: a, b: b, c: c}, d, e, f, %Four{a: g, b: h, c: i, d: j}, m2),
    do: append4(m1, node3(a, b, c), node3(d, e, f), node2(g, h), node2(i, j), m2)


  # Four
  defp add_digits3(m1, %Four{a: a, b: b, c: c, d: d}, e, f, g, %One{a: h}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node2(g, h), m2)

  defp add_digits3(m1, %Four{a: a, b: b, c: c, d: d}, e, f, g, %Two{a: h, b: i}, m2),
    do: append3(m1, node3(a, b, c), node3(d, e, f), node3(g, h, i), m2)

  defp add_digits3(m1, %Four{a: a, b: b, c: c, d: d}, e, f, g, %Three{a: h, b: i, c: j}, m2),
    do: append4(m1, node3(a, b, c), node3(d, e, f), node2(g, h), node2(i, j), m2)

  defp add_digits3(m1, %Four{a: a, b: b, c: c, d: d}, e, f, g, %Four{a: h, b: i, c: j, d: k}, m2),
    do: append4(m1, node3(a, b, c), node3(d, e, f), node3(g, h, i), node2(j, k), m2)




  defp append4(%Empty{}, a, b, c, d, xs),
    do: xs |> cons(d) |> cons(c) |> cons(b) |> cons(a)

  defp append4(xs, a, b, c, d, %Empty{}),
    do: xs |> snoc(a) |> snoc(b) |> snoc(c) |> snoc(d)

  defp append4(%Single{x: x}, a, b, c, d, xs),
    do: xs |> cons(d) |> cons(c) |> cons(b) |> cons(a) |> cons(x)

  defp append4(xs, a, b, c, d, %Single{x: x}),
    do: xs |> snoc(a) |> snoc(b) |> snoc(c) |> snoc(d) |> snoc(x)

  defp append4(%Deep{
        monoid: mo,
        size: s1,
        l: pr1,
        m: m1,
        r: sf1
               },
    a, b, c, d,
    %Deep{
        monoid: mo,
        size: s2,
        l: pr2,
        m: m2,
        r: sf2
               }
    ),
    do: %Deep{
          monoid: mo,
          size: Monoid.mappend(
            s1,
            Monoid.mappend(
              Measured.size(a),
              Monoid.mappend(
                Measured.size(b),
                Monoid.mappend(
                  Measured.size(c),
                  Monoid.mappend(
                    Measured.size(d),
                    s2
                  )
                )
              )
            )
          ),
          l: pr1,
          m: add_digits4(m1, sf1, a, b, c, d, pr2, m2),
          r: sf2
    }

end
