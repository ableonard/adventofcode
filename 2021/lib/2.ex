import AocHelpers

defmodule Aoc2021.Day2 do
  def part_1 do
    file_to_stream("d2")
    |> Enum.reduce(%{:hpos => 0, :depth => 0}, &part_1_reducer/2)
  end

  def part_2 do
    file_to_stream("d2")
    |> Enum.reduce(%{:hpos => 0, :depth => 0, :aim => 0}, &part_2_reducer/2)
  end

  defp part_1_reducer(elem, acc) do
    [direction, distance] = String.split(elem)
    distance = String.to_integer(distance)
    case direction do
      "forward" -> Map.put(acc, :hpos, acc[:hpos] + distance)
      "down" -> Map.put(acc, :depth, acc[:depth] + distance)
      "up" -> Map.put(acc, :depth, acc[:depth] - distance)
    end
  end

  defp part_2_reducer(elem, acc) do
    IO.inspect(acc)
    IO.puts(elem)
    [direction, distance] = String.split(elem)
    distance = String.to_integer(distance)
    case direction do
      "forward" -> %{:hpos => acc[:hpos] + distance, :depth => acc[:depth] + (acc[:aim] * distance), :aim => acc[:aim]}
      "down" -> Map.put(acc, :aim, acc[:aim] + distance)
      "up" -> Map.put(acc, :aim, acc[:aim] - distance)
    end
  end
end
