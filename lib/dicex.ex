defmodule Dicex do
  @moduledoc """
  Documentation for `Dicex`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Dicex.hello()
      :world

  """

  def roll(sides) do
    result = :rand.uniform(sides)
    IO.inspect("Rolled d#{sides}: #{result}")
    result
  end

  def roll(sides, times) do
    1..times
    |> Enum.map(fn _ -> roll(sides) end)
    |> Enum.sum()
  end

  def run(string) do
    string
    |> String.to_charlist()
    |> :tokens.string()
    |> elem(1)
    |> IO.inspect()
    |> :grammar.parse()
    |> IO.inspect()
  end
end
