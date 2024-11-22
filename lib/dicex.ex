defmodule Dicex do
  @moduledoc """
  Documentation for `Dicex`.
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
    |> :grammar.parse()
  end
end
