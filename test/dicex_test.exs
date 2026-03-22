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

  test "roll exploding single die" do
    {:ok, {rolls, total}} = Dicex.roll("d6!")

    assert Enum.all?(rolls, fn {sides, _} -> sides == 6 end)
    assert Enum.all?(rolls, fn {_, result} -> result in 1..6 end)
    assert total == Enum.reduce(rolls, 0, fn {_, r}, acc -> acc + r end)
    assert length(rolls) >= 1

    if length(rolls) > 1 do
      {leading, [last]} = Enum.split(rolls, length(rolls) - 1)
      assert Enum.all?(leading, fn {_, result} -> result == 6 end)
      assert elem(last, 1) in 1..5
    end
  end

  test "roll exploding multiple dice" do
    {:ok, {rolls, total}} = Dicex.roll("2d6!")

    assert Enum.all?(rolls, fn {sides, _} -> sides == 6 end)
    assert Enum.all?(rolls, fn {_, result} -> result in 1..6 end)
    assert total == Enum.reduce(rolls, 0, fn {_, r}, acc -> acc + r end)
    assert length(rolls) >= 2
  end

  test "exploding dice in expression" do
    {:ok, {rolls, total}} = Dicex.roll("d6! + 3")

    die_rolls = Enum.filter(rolls, fn {sides, _} -> sides == 6 end)
    die_total = Enum.reduce(die_rolls, 0, fn {_, r}, acc -> acc + r end)
    assert total == die_total + 3
  end

  test "exploding d1 respects safety cap" do
    {:ok, {rolls, total}} = Dicex.roll("d1!")

    assert length(rolls) == 100
    assert total == 100
  end

  test "ampersand separates independent groups" do
    {:ok, results} = Dicex.roll("1d6 & 1d8")
    assert length(results) == 2

    [{rolls1, total1}, {rolls2, total2}] = results
    assert Enum.all?(rolls1, fn {sides, _} -> sides == 6 end)
    assert Enum.all?(rolls2, fn {sides, _} -> sides == 8 end)
    assert total1 == Enum.reduce(rolls1, 0, fn {_, r}, acc -> acc + r end)
    assert total2 == Enum.reduce(rolls2, 0, fn {_, r}, acc -> acc + r end)
  end

  test "ampersand with trailing modifier broadcasts to all groups" do
    {:ok, results} = Dicex.roll("1d6 & 1d8 + 3")
    assert length(results) == 2

    [{rolls1, total1}, {rolls2, total2}] = results
    die_total1 = Enum.reduce(rolls1, 0, fn {_, r}, acc -> acc + r end)
    die_total2 = Enum.reduce(rolls2, 0, fn {_, r}, acc -> acc + r end)

    assert total1 == die_total1 + 3
    assert total2 == die_total2 + 3
  end

  test "ampersand with group-local and broadcast modifiers" do
    {:ok, results} = Dicex.roll("1d6 + 2 & 1d8 + 3")
    assert length(results) == 2

    [{rolls1, total1}, {rolls2, total2}] = results
    die_total1 = Enum.reduce(Enum.filter(rolls1, fn {s, _} -> s == 6 end), 0, fn {_, r}, acc -> acc + r end)
    die_total2 = Enum.reduce(Enum.filter(rolls2, fn {s, _} -> s == 8 end), 0, fn {_, r}, acc -> acc + r end)

    assert total1 == die_total1 + 2 + 3
    assert total2 == die_total2 + 3
  end

  test "ampersand with exploding dice" do
    {:ok, results} = Dicex.roll("1d6! & 1d8!")
    assert length(results) == 2

    [{rolls1, total1}, {rolls2, total2}] = results
    assert Enum.all?(rolls1, fn {sides, _} -> sides == 6 end)
    assert Enum.all?(rolls2, fn {sides, _} -> sides == 8 end)
    assert total1 == Enum.reduce(rolls1, 0, fn {_, r}, acc -> acc + r end)
    assert total2 == Enum.reduce(rolls2, 0, fn {_, r}, acc -> acc + r end)
  end

  test "ampersand with three groups" do
    {:ok, results} = Dicex.roll("1d4 & 1d6 & 1d8")
    assert length(results) == 3
  end

  test "no ampersand preserves original return type" do
    {:ok, {rolls, total}} = Dicex.roll("2d6")
    assert is_list(rolls)
    assert is_integer(total)
  end
end
