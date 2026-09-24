defmodule DicexTest do
  use ExUnit.Case

  test "roll a single die" do
    {:ok, [{[{dice, roll}], total}]} = Dicex.roll("d6")

    assert dice == 6
    assert roll == 1
    assert total == roll
  end

  test "roll multiple dice" do
    {:ok, [{[{dice, roll}, {dice, roll2}], total}]} = Dicex.roll("2d6")

    assert dice == 6
    assert roll == 1
    assert roll2 == 4
    assert total == roll + roll2
  end

  test "roll explosion" do
    {:ok, [{[{dice, roll}, {dice, exploded_roll}, {dice, roll2}], total}]} = Dicex.roll("2d3!")

    assert dice == 3
    assert roll == 3
    assert exploded_roll == 1
    assert roll2 == 1
    assert total == roll + exploded_roll + roll2
  end

  test "multiple rolls" do
    {:ok, [{[{dice, roll}], total}, {[{dice2, roll2}, {dice2, roll3}], total2}]} =
      Dicex.roll("1d4, 2d6")

    assert dice == 4
    assert roll == 2
    assert total == roll

    assert dice2 == 6
    assert roll2 == 3
    assert roll3 == 4
    assert total2 == roll2 + roll3
  end

  test "invalid roll" do
    {:error, _} = Dicex.roll("2d6d6")
  end

  test "different invalid roll" do
    {:error, _} = Dicex.roll("-1")
  end
end
