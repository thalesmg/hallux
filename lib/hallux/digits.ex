defmodule Hallux.Digits do
  alias __MODULE__.{One, Two, Three, Four}

  def popL(digit) do
    case digit do
      %One{a: a} ->
        {a, []}
      %Two{a: a, b: b} ->
        {a, [b]}
      %Three{a: a, b: b, c: c} ->
        {a, [b,c]}
      %Four{a: a, b: b, c: c, d: d} ->
        {a, [b,c,d]}
    end
  end

  def to_digits([a]), do: %One{a: a}
  def to_digits([a,b]), do: %Two{a: a, b: b}
  def to_digits([a,b,c]), do: %Three{a: a, b: b, c: c}
  def to_digits([a,b,c,d]), do: %Four{a: a, b: b, c: c, d: d}

end
