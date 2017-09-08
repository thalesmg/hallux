defmodule Hallux.Views do
  defmodule NilL, do: (defstruct [])
  defmodule ConsL, do: (defstruct [:hd, :tl])

  def nilL(), do: %__MODULE__.NilL{}
  def consL(hd, tl), do: %__MODULE__.ConsL{hd: hd, tl: tl}
end
