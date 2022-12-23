import AocHelpers

defmodule Aoc2021.Day3 do
  def part_1 do
    file_to_stream("d3")
    |> Enum.reduce(List.duplicate({0,0}, 12), &bit_frequencies/2)
    |> tap(&IO.inspect/1)
    |> calc_gamma_epsilon
  end

  def part_2 do
    lines = Enum.to_list(file_to_stream("d3ex"))
    size = length(hd(lines))
    IO.inspect(lines)
    freqs = Enum.reduce(lines, List.duplicate({0,0}, size), &bit_frequencies/2)
    IO.inspect(freqs)
    IO.puts("O2")
    test = Enum.reduce_while(1..size), lines, &keep_char_at_v2/2)
    o2_bits = freqs
      |> Enum.map(&max_index/1)
      |> Enum.map(&Integer.to_string/1)
      |> Enum.with_index()
    {o2, _} = Integer.parse(hd(Enum.reduce_while(o2_bits, lines, &keep_char_at/2)), 2)
    IO.puts("CO2")
    co2_bits = freqs
      |> Enum.map(&min_index/1)
      |> Enum.map(&Integer.to_string/1)
      |> Enum.with_index()
    {co2, _} = Integer.parse(hd(Enum.reduce_while(co2_bits, lines, &keep_char_at/2)), 2)
    %{
      :o2 => o2,
      :co2 => co2
    }
  end

  defp keep_char_at(char_and_index, values) do
    {char, index} = char_and_index
    IO.inspect(values)
    IO.inspect(char_and_index)
    if length(values) > 1 do
      {:cont, Enum.filter(values, fn(v) -> String.at(v, index) == char end)}
    else
      {:halt, values}
    end
  end

  defp keep_char_at_v2(index, values) do
    freqs = Enum.reduce(values, List.duplicate({0,0}, length(hd(values))), &bit_frequencies/2)

  end

  defp inc_counter(bitAndCounter) do
    {bit, counter} = bitAndCounter
    case bit do
      "0" -> {elem(counter, 0) + 1, elem(counter, 1)}
      "1" -> {elem(counter, 0), elem(counter, 1) + 1}
    end
  end

  defp bit_frequencies(elem, acc) do
    String.graphemes(elem)
    |> Enum.zip(acc)
    |> Enum.map(&inc_counter/1)
  end

  defp max_index(tuple) do
    {first, second} = tuple
    cond do
      first > second -> 0
      first < second -> 1
      true -> 1
    end
  end

  defp min_index(tuple) do
    {first, second} = tuple
    cond do
      first < second -> 0
      first > second -> 1
      true -> 0
    end
  end

  defp calc_gamma_epsilon(bit_counts) do
    {gamma, _} = bit_counts
      |> Enum.map(&max_index/1)
      |> Enum.join("")
      |> Integer.parse(2)
    {epsilon, _} = bit_counts
      |> Enum.map(&min_index/1)
      |> Enum.join("")
      |> Integer.parse(2)
    %{
      :gamma => gamma,
      :epsilon => epsilon
    }
  end
end
