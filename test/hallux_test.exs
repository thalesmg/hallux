defmodule HalluxTest do
  use ExUnit.Case
  doctest Hallux

  test "greets the world" do
    assert Hallux.hello() == :world
  end
end
