defmodule DicexTest do
  use ExUnit.Case
  doctest Dicex

  test "roll a single die" do
    {:ok, {[{dice, roll}], total}} = Dicex.roll("d6")

    assert dice == 6
    assert roll in 1..6
    assert total == roll
  end

  test "roll multiple dice" do
    {:ok, {[{dice, roll}, {dice, roll2}], total}} = Dicex.roll("2d6")

    assert dice == 6
    assert roll in 1..6
    assert roll2 in 1..6
    assert total == roll + roll2
  end

  test "invalid roll" do
    {:error, _} = Dicex.roll("2d6d6")
  end

  test "different invalid roll" do
    {:error, _} = Dicex.roll("-1")
  end
end
