defmodule Dicex do
  @moduledoc """
  Documentation for `Dicex`.
  """

  require Logger

  @spec roll(String.t()) :: {:ok, {[{integer(), integer()}], integer()}} | {:error, any()}
  def roll(string) when is_binary(string) do
    string
    |> String.to_charlist()
    |> :tokens.string()
    |> elem(1)
    |> :grammar.parse()
  rescue
    error -> {:error, error}
  end

  def roll(sides) when is_integer(sides) do
    :rand.uniform(sides)
  end

  def roll(sides, times) do
    {_rolls, total} = roll_detail(sides, times)
    total
  end

  def explode_roll(sides) do
    {:explode, sides, do_explode_roll(sides, [])}
  end

  defp do_explode_roll(sides, acc) do
    result = roll(sides)
    if result == sides do
      do_explode_roll(sides, [result | acc])
    else
      Enum.reverse([result | acc])
    end
  end

  def roll_detail(sides, times) do
    rolls = Enum.map(1..times, fn _ -> {:roll, sides, roll(sides)} end)
    {rolls, Enum.reduce(rolls, 0, fn {_, _, result}, acc -> acc + result end)}
  end

  def roll_explode_detail(sides, times) do
    rolls = Enum.map(1..times, fn -> explode_roll(sides) end)
  end
end
