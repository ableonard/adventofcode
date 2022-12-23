import AocHelpers

defmodule Aoc2021.Day1 do
  def part_1 do
    file_to_stream("d1")
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(%{:last => -1, :count => -1}, &part_1_summer/2)
    |> Map.get(:count)
  end

  def part_2 do
    file_to_stream("d1")
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.reduce(%{:last => -1, :count => -1}, &part_2_summer/2)
    |> Map.get(:count)
  end

  defp part_1_summer(elem, acc) do
    if acc[:last] < elem do
      %{:last => elem, :count => acc[:count] + 1}
    else
      Map.put(acc, :last, elem)
    end
  end

  defp part_2_summer(elem, acc) do
    sum = Enum.sum(elem)
    if acc[:last] < sum do
      %{:last => sum, :count => acc[:count] + 1}
    else
      Map.put(acc, :last, sum)
    end
  end
end
