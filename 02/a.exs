defmodule InvalidIDs do
  def run(file) do
    File.read!(file)
    |> String.split(",")
    |> Enum.map(&parse_range/1)
    |> Enum.map(fn range -> {range, find_invalid(range)} end)
    |> IO.inspect(limit: :infinity)
    |> Enum.map(fn {_, ids} -> Enum.sum(ids) end)
    |> Enum.sum()
    |> IO.inspect(label: "sum")
  end

  defp parse_range(line) do
    [min, max] =
      line
      |> String.trim()
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    min..max
  end

  defp find_invalid(min..max//_) do
    leading_half_digits(min)
    |> invalid_id_stream()
    |> Stream.drop_while(fn n -> n < min end)
    |> Stream.take_while(fn n -> n <= max end)
    |> Enum.to_list()
  end

  defp leading_half_digits(num) do
    str = Integer.to_string(num)
    len = String.length(str)

    case len do
      1 ->
        # Single digit start points will ignore the input and start with 1 (i.e. 11).
        1

      n when n >= 2 ->
        str
        |> String.slice(0, div(len, 2))
        |> String.to_integer()
    end
  end

  # Given e.g. start = 123,
  # will generate an infinite stream of [123123, 124124, 125125, ...]
  defp invalid_id_stream(start) do
    Stream.iterate(start, &(&1 + 1))
    |> Stream.map(fn n -> String.to_integer("#{n}#{n}") end)
  end
end

[file] = System.argv()
InvalidIDs.run(file)
