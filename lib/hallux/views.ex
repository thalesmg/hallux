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


defimpl Enumerable, for: Hallux.Views.NilL do
  def count(_nilL), do: {:ok, 0}
  def member?(_nilL, _elem), do: {:ok, false}

  def reduce(_nilL, {:halt, acc}, _fun) do
    {:halted, acc}
  end
  def reduce(nilL, {:suspend, acc}, fun) do
    {:suspended, acc, & fun.(nilL, &1, fun)}
  end
  def reduce(_nilL, {:cont, acc}, _fun) do
    {:done, acc}
  end
end

defimpl Enumerable, for: Hallux.Views.ConsL do
  def count(consL), do: {:error, __MODULE__}
  def member?(consL, elem), do: {:error, __MODULE__}

  def reduce(_consL, {:halt, acc}, _fun) do
    {:halted, acc}
  end
  def reduce(consL, {:suspend, acc}, fun) do
    {:suspended, acc, & fun.(consL, &1, fun)}
  end
  def reduce(consL, {:cont, acc}, fun) do
    case Hallux.viewL(consL.tl) do
      %Hallux.Views.NilL{} ->
        {:cont, result} = fun.(consL.hd, acc)
        {:done, result}
      %Hallux.Views.ConsL{} = tl ->
        reduce(tl, fun.(consL.hd, acc), fun)
    end
  end
end

defimpl Enumerable, for: Hallux.Views.NilR do
  def count(_nilR), do: {:ok, 0}
  def member?(_nilR, _elem), do: {:ok, false}

  def reduce(_nilR, {:halt, acc}, _fun) do
    {:halted, acc}
  end
  def reduce(nilR, {:suspend, acc}, fun) do
    {:suspended, acc, & fun.(nilR, &1, fun)}
  end
  def reduce(_nilR, {:cont, acc}, _fun) do
    {:done, acc}
  end
end

defimpl Enumerable, for: Hallux.Views.ConsR do
  def count(consR), do: {:error, __MODULE__}
  def member?(consR, elem), do: {:error, __MODULE__}

  def reduce(_consR, {:halt, acc}, _fun) do
    {:halted, acc}
  end
  def reduce(consR, {:suspend, acc}, fun) do
    {:suspended, acc, & fun.(consR, &1, fun)}
  end
  def reduce(consR, {:cont, acc}, fun) do
    case Hallux.viewR(consR.tl) do
      %Hallux.Views.NilR{} ->
        {:cont, result} = fun.(consR.hd, acc)
        {:done, result}
      %Hallux.Views.ConsR{} = tl ->
        reduce(tl, fun.(consR.hd, acc), fun)
    end
  end
end
