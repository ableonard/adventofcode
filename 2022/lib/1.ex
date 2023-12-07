import AocHelpers

defmodule Aoc2021.Day1 do
  def part_1 do
    file_to_stream("d1")
    |> Enum.chunk_by(fn elem -> elem == "" end)
    |> Enum.map(&Enum.sum/1)
    |> Enum.with_index()
    |> Enum.sort(fn tup1, tup2 -> elem(tup1, 0) <= elem(tup2, 0) end)
    |> Enum.at(0)
    |> elem(1)
  end
end
