defmodule DicexTest do
  use ExUnit.Case
  doctest Dicex

  test "greets the world" do
    assert Dicex.hello() == :world
  end
end
