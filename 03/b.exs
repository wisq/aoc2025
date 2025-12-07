defmodule Elevator do
  def run(file) do
    File.stream!(file)
    |> Enum.map(&parse/1)
    |> Enum.map(&max_joltage(&1, 12))
    |> IO.inspect()
    |> Enum.sum()
    |> IO.inspect(label: "sum")
  end

  defp parse(line) do
    line
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  defp max_joltage(batteries, 1), do: Enum.max(batteries)

  defp max_joltage(batteries, size) do
    {digit, index} =
      batteries
      # can't start a 12-digit number with any of the last 11 digits
      |> Enum.drop(1 - size)
      |> Enum.with_index()
      # highest digit, lowest index
      |> Enum.min_by(fn {n, i} -> {-n, i} end)

    next_digit =
      batteries
      |> Enum.drop(index + 1)
      |> max_joltage(size - 1)

    digit * 10 ** (size - 1) + next_digit
  end
end

[file] = System.argv()
Elevator.run(file)
