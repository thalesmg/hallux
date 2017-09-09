defmodule Hallux.Views do
  defmodule NilL, do: (defstruct [])
  defmodule ConsL, do: (defstruct [:hd, :tl])

  defmodule NilR, do: (defstruct [])
  defmodule ConsR, do: (defstruct [:hd, :tl])

  def nilL(), do: %__MODULE__.NilL{}
  def consL(hd, tl), do: %__MODULE__.ConsL{hd: hd, tl: tl}

  def nilR(), do: %__MODULE__.NilR{}
  def consR(hd, tl), do: %__MODULE__.ConsR{hd: hd, tl: tl}
end
