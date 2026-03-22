defmodule Dicex do
  @moduledoc """
  Documentation for `Dicex`.
  """

  require Logger

  @explode_cap 100

  @type roll_result :: {[{integer(), integer()}], integer()}

  @spec roll(String.t()) :: {:ok, roll_result()} | {:ok, [roll_result()]} | {:error, any()}
  def roll(string) when is_binary(string) do
    with {:ok, tokens} <- tokenize(string) do
      if has_ampersand?(tokens) do
        roll_groups(tokens)
      else
        :grammar.parse(tokens)
      end
    end
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

  def roll_detail(sides, times) do
    rolls = Enum.map(1..times, fn _ -> {sides, roll(sides)} end)
    {rolls, Enum.reduce(rolls, 0, fn {_, result}, acc -> acc + result end)}
  end

  def roll_detail_exploding(sides, times) do
    rolls = Enum.flat_map(1..times, fn _ -> roll_exploding(sides, []) end)
    {rolls, Enum.reduce(rolls, 0, fn {_, result}, acc -> acc + result end)}
  end

  defp tokenize(string) do
    case string |> String.to_charlist() |> :tokens.string() do
      {:ok, tokens, _end_line} -> {:ok, tokens}
      {:error, reason, _end_line} -> {:error, reason}
    end
  end

  defp has_ampersand?(tokens) do
    Enum.any?(tokens, fn
      {:&, _} -> true
      _ -> false
    end)
  end

  defp split_on_ampersand(tokens) do
    tokens
    |> Enum.chunk_by(fn
      {:&, _} -> :separator
      _ -> :token
    end)
    |> Enum.reject(fn chunk -> match?([{:&, _} | _], chunk) end)
  end

  defp extract_trailing_modifier(last_group) do
    last_d_index =
      last_group
      |> Enum.with_index()
      |> Enum.filter(fn {tok, _idx} -> elem(tok, 0) == :d end)
      |> List.last()

    case last_d_index do
      nil ->
        {last_group, []}

      {_d_token, d_idx} ->
        end_of_dice =
          if length(last_group) > d_idx + 2 &&
               elem(Enum.at(last_group, d_idx + 2), 0) == :! do
            d_idx + 2
          else
            d_idx + 1
          end

        dice_part = Enum.take(last_group, end_of_dice + 1)
        modifier_part = Enum.drop(last_group, end_of_dice + 1)
        {dice_part, modifier_part}
    end
  end

  defp roll_groups(tokens) do
    groups = split_on_ampersand(tokens)

    case groups do
      [] ->
        {:error, :empty_expression}

      _ ->
        last_group = List.last(groups)
        {last_dice_part, trailing_modifier} = extract_trailing_modifier(last_group)

        all_but_last = Enum.slice(groups, 0, length(groups) - 1)
        adjusted_groups = all_but_last ++ [last_dice_part]

        results =
          Enum.map(adjusted_groups, fn group_tokens ->
            :grammar.parse(group_tokens ++ trailing_modifier)
          end)

        case Enum.find(results, fn {:error, _} -> true; _ -> false end) do
          nil ->
            {:ok, Enum.map(results, fn {:ok, result} -> result end)}

          error ->
            error
        end
    end
  end

  defp roll_exploding(_sides, acc) when length(acc) >= @explode_cap do
    Enum.reverse(acc)
  end

  defp roll_exploding(sides, acc) do
    result = roll(sides)
    new_acc = [{sides, result} | acc]

    if result == sides do
      roll_exploding(sides, new_acc)
    else
      Enum.reverse(new_acc)
    end
  end
end
