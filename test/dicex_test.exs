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

  # Below, "d1" is used wherever a deterministic dice value is needed: it always
  # rolls 1, so exact roll lists and totals can be asserted without depending on
  # the RNG seed. Random dice are checked with structural properties instead.

  describe "arithmetic" do
    test "adds a constant to a roll" do
      assert {:ok, [{[{1, 1}, {1, 1}, {1, 1}], 5}]} = Dicex.roll("3d1+2")
    end

    test "subtracts a constant from a roll" do
      assert {:ok, [{[{1, 1}, {1, 1}, {1, 1}], 2}]} = Dicex.roll("3d1-1")
    end

    test "multiplies a roll by a constant" do
      assert {:ok, [{[{1, 1}, {1, 1}], 10}]} = Dicex.roll("2d1*5")
    end

    test "divides using integer division, truncating towards zero" do
      assert {:ok, [{[], 3}]} = Dicex.roll("7/2")
      assert {:ok, [{rolls, 4}]} = Dicex.roll("9d1/2")
      assert length(rolls) == 9
    end

    test "allows a constant on the left of an operator" do
      assert {:ok, [{[{1, 1}], 10}]} = Dicex.roll("10/d1")
      assert {:ok, [{[{1, 1}, {1, 1}, {1, 1}], 6}]} = Dicex.roll("2*3d1")
    end

    test "combines two dice expressions, concatenating their rolls in order" do
      assert {:ok, [{[{4, a}, {6, b}], total}]} = Dicex.roll("1d4+1d6")
      assert a in 1..4
      assert b in 1..6
      assert total == a + b

      assert {:ok, [{[{1, 1}, {1, 1}, {1, 1}], 2}]} = Dicex.roll("2d1*1d1")
    end

    test "subtraction can produce a negative total" do
      assert {:ok, [{[{1, 1}, {1, 1}, {1, 1}], -1}]} = Dicex.roll("1d1-2d1")
    end

    test "multiplication and division bind tighter than addition and subtraction" do
      assert {:ok, [{[], 14}]} = Dicex.roll("2+3*4")
      assert {:ok, [{[], 10}]} = Dicex.roll("2*3+4")
      assert {:ok, [{[], 6}]} = Dicex.roll("10/2+1")
      assert {:ok, [{[], 7}]} = Dicex.roll("10-6/2")
    end

    test "addition and subtraction evaluate left to right" do
      assert {:ok, [{[], 5}]} = Dicex.roll("10-3-2")
      assert {:ok, [{[], 2}]} = Dicex.roll("1-2+3")
      assert {:ok, [{[], 6}]} = Dicex.roll("5+2-1")
    end

    test "multiplication and division evaluate left to right" do
      assert {:ok, [{[], 3}]} = Dicex.roll("24/4/2")
      assert {:ok, [{[], 9}]} = Dicex.roll("6/2*3")
      assert {:ok, [{[], 4}]} = Dicex.roll("6*2/3")
    end

    test "evaluates constant-only expressions with an empty roll list" do
      assert {:ok, [{[], 5}]} = Dicex.roll("2+3")
    end

    test "returns a bare constant in the same shape as other results" do
      assert {:ok, [{[], 5}]} = Dicex.roll("5")
      assert {:ok, [{[], 1}, {[], 2}]} = Dicex.roll("1,2")
    end

    test "division by zero returns an error rather than raising" do
      assert {:error, %ArithmeticError{}} = Dicex.roll("1/0")
      assert {:error, %ArithmeticError{}} = Dicex.roll("2d6/0")
    end
  end

  describe "notation variants" do
    test "accepts an uppercase D" do
      assert {:ok, [{[{1, 1}, {1, 1}], 2}]} = Dicex.roll("2D1")
    end

    test "accepts x as a multiplication operator" do
      assert {:ok, [{[], 6}]} = Dicex.roll("2x3")
      assert {:ok, [{[{1, 1}], 3}]} = Dicex.roll("d1x3")
    end

    test "treats % as a 100-sided die" do
      assert {:ok, [{[{100, value}], value}]} = Dicex.roll("d%")
      assert value in 1..100

      assert {:ok, [{[{100, a}, {100, b}], total}]} = Dicex.roll("2d%")
      assert total == a + b
    end

    test "ignores spaces, tabs and newlines anywhere in the expression" do
      assert {:ok, [{[{1, 1}, {1, 1}], 3}]} = Dicex.roll(" 2d1 \n+\t1 ")
      assert {:ok, [{[{1, 1}, {1, 1}], 2}]} = Dicex.roll("2 d 1")
      assert {:ok, [{[{1, 1}], 1}, {[{1, 1}], 1}]} = Dicex.roll("d1 ,\n d1")
    end
  end

  describe "dice" do
    test "every rolled value is within range and the total is their sum" do
      for _ <- 1..25 do
        assert {:ok, [{rolls, total}]} = Dicex.roll("10d6")
        assert length(rolls) == 10
        assert_valid_rolls(rolls, total, 6)
      end
    end

    test "a single die without a count is rolled once" do
      for _ <- 1..25 do
        assert {:ok, [{[{20, _}] = rolls, total}]} = Dicex.roll("d20")
        assert_valid_rolls(rolls, total, 20)
      end
    end

    test "handles a large number of dice" do
      assert {:ok, [{rolls, 100}]} = Dicex.roll("100d1")
      assert length(rolls) == 100
      assert Enum.all?(rolls, &(&1 == {1, 1}))
    end

    test "handles dice with a large number of sides" do
      assert {:ok, [{[{1_000_000, value}], value}]} = Dicex.roll("d1000000")
      assert value in 1..1_000_000
    end

    test "zero dice produces no rolls and a total of zero" do
      assert {:ok, [{[], 0}]} = Dicex.roll("0d6")
    end
  end

  describe "exploding dice" do
    test "a die that always explodes is capped at 50 rolls" do
      assert {:ok, [{rolls, 50}]} = Dicex.roll("1d1!")
      assert length(rolls) == 50
      assert Enum.all?(rolls, &(&1 == {1, 1}))

      assert {:ok, [{rolls, 50}]} = Dicex.roll("d1!")
      assert length(rolls) == 50
    end

    test "the explosion cap applies to each die independently" do
      assert {:ok, [{rolls, 100}]} = Dicex.roll("2d1!")
      assert length(rolls) == 100
    end

    test "explosions only follow maximum rolls" do
      for _ <- 1..25 do
        assert {:ok, [{rolls, total}]} = Dicex.roll("5d4!")
        assert_valid_rolls(rolls, total, 4)

        # There are at least as many rolls as dice requested, and every extra
        # roll must have been triggered by a maximum roll.
        extra_rolls = length(rolls) - 5
        max_rolls = Enum.count(rolls, fn {_, value} -> value == 4 end)
        assert extra_rolls >= 0
        assert max_rolls >= extra_rolls
      end
    end

    test "exploding rolls combine with arithmetic and other rolls" do
      assert {:ok, [{rolls, 51}]} = Dicex.roll("1d1!+1")
      assert length(rolls) == 50

      assert {:ok, [{exploded, 50}, {[{1, 1}], 1}]} = Dicex.roll("d1!, d1")
      assert length(exploded) == 50
    end
  end

  describe "multiple rolls" do
    test "supports three or more comma-separated rolls" do
      assert {:ok, [{[{1, 1}], 1}, {[{1, 1}, {1, 1}], 2}, {[{1, 1}, {1, 1}, {1, 1}], 3}]} =
               Dicex.roll("d1,2d1,3d1")
    end

    test "each roll in the list may contain its own arithmetic" do
      assert {:ok, [{[{1, 1}], 2}, {[{1, 1}, {1, 1}], 6}]} = Dicex.roll("1d1+1, 2d1*3")
    end
  end

  describe "invalid input" do
    test "an empty string is an error" do
      assert {:error, _} = Dicex.roll("")
      assert {:error, _} = Dicex.roll("   ")
    end

    test "incomplete dice notation is an error" do
      for input <- ["d", "2d", "2d6+", "*2", "2d6 d", "2d6!!"] do
        assert {:error, _} = Dicex.roll(input), "expected #{inspect(input)} to be an error"
      end
    end

    test "leading, trailing or doubled commas are an error" do
      for input <- ["2d6,", ",2d6", "1,,2", ","] do
        assert {:error, _} = Dicex.roll(input), "expected #{inspect(input)} to be an error"
      end
    end

    test "unrecognised characters are an error" do
      for input <- ["abc", "2d6#", "1.5", "2d6 + foo", "2d6 ✓"] do
        assert {:error, _} = Dicex.roll(input), "expected #{inspect(input)} to be an error"
      end
    end

    test "a zero-sided die is an error" do
      assert {:error, _} = Dicex.roll("1d0")
      assert {:error, _} = Dicex.roll("d0!")
    end
  end

  # Asserts every roll used the expected die, every value is within range, and
  # the total is the sum of the values.
  defp assert_valid_rolls(rolls, total, sides) do
    for {die, value} <- rolls do
      assert die == sides
      assert value in 1..sides
    end

    assert total == Enum.sum(Enum.map(rolls, fn {_, value} -> value end))
  end
end
