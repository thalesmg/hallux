defmodule Hallux.Internal.Digit do
  alias Hallux.Internal.Digit.One
  alias Hallux.Internal.Digit.Two
  alias Hallux.Internal.Digit.Three
  alias Hallux.Internal.Digit.Four

  @type value :: term
  @opaque t(value) ::
            %One{a: value}
            | %Two{a: value, b: value}
            | %Three{a: value, b: value, c: value}
            | %Four{a: value, b: value, c: value, d: value}
  @type t :: t(term)
end
