defmodule Dicex do
  @moduledoc """
  Documentation for `Dicex`.
  """

  @type dice :: integer()
  @type rolled_value :: integer()
  @type roll :: {dice(), rolled_value()}
  @type roll_sum :: integer()
  @type roll_result :: {[roll()], roll_sum()}
  @type roll_list :: [roll_result()]

  @doc """
  Returns a list of rolls and the total of the rolls.

  ## Examples

      iex> Dicex.roll("2d6")
      {:ok, [{[{6, 3}, {6, 5}], 8}]}

      iex> Dicex.roll("1d4, 2d6")
      {:ok, [{[{4, 2}], 2}, {[{6, 3}, {6, 2}], 6}]}

      iex> Dicex.roll("invalid input")
      {:error, _}

  """
  @spec roll(String.t()) :: {:ok, {roll_list(), roll_sum()}} | {:error, any()}
  def roll(string) when is_binary(string) do
    string
    |> String.to_charlist()
    |> :tokens.string()
    |> elem(1)
    |> :grammar.parse()
  rescue
    error -> {:error, error}
  end

  # Simple roll of a die with a given number of sides.
  @spec roll_die(integer()) :: integer()
  defp roll_die(sides) do
    :rand.uniform(sides)
  end

  defp do_explode_roll(_sides, acc) when length(acc) == 50 do
    Enum.reverse(acc)
  end

  defp do_explode_roll(sides, acc) do
    this_roll = roll_die(sides)
    roll_list = [{sides, this_roll} | acc]

    if this_roll == sides do
      do_explode_roll(sides, roll_list)
    else
      Enum.reverse(roll_list)
    end
  end

  def roll_detail(sides, times) do
    1..times |> Enum.map(fn _ -> {sides, roll_die(sides)} end) |> collate_output()
  end

  def roll_explode_detail(sides, times) do
    1..times
    |> Enum.map(fn _ -> do_explode_roll(sides, []) end)
    |> List.flatten()
    |> collate_output()
  end

  defp collate_output(rolls) do
    {rolls, Enum.reduce(rolls, 0, fn {_, result}, acc -> acc + result end)}
  end
end
