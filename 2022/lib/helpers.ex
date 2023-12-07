defmodule AocHelpers do

  def input_path(name) do
    "input/#{name}.in"
  end

  def file_to_string(name) do
    name
    |> input_path()
    |> File.read!
  end

  def file_to_stream(name) do
    name
    |> input_path()
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end
end
