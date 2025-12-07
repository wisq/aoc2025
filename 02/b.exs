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
    possible_slices(max)
    |> IO.inspect(label: "#{min}..#{max} slices")
    |> Enum.flat_map(fn {count, size} ->
      leading_digits(min, count, size)
      |> invalid_id_stream(count)
      |> Stream.drop_while(fn n -> n < min end)
      |> Stream.take_while(fn n -> n <= max end)
      |> Stream.each(fn n -> IO.inspect(n, label: "#{min}..#{max} #{count}x#{size}") end)
    end)
    |> Enum.uniq()
  end

  defp possible_slices(num) do
    str = Integer.to_string(num)
    len = String.length(str)

    1..len
    |> Enum.map(fn size ->
      {size, div(len, size)}
    end)
    |> Enum.filter(fn {count, size} -> count > 1 && size > 0 end)
  end

  defp leading_digits(num, count, size) do
    str = Integer.to_string(num)

    if count * size > String.length(str) do
      1
    else
      str
      |> String.slice(0, size)
      |> String.to_integer()
    end
  end

  # Given e.g. start = 123 and count = 2,
  # will generate a stream of [123123, 124124, 125125, ...]
  #
  # or start = 45 and count = 5,
  # will generate an infinite stream of [4545454545, 4646464646, 4747474747, ...]
  defp invalid_id_stream(start, count) do
    Stream.iterate(start, &(&1 + 1))
    |> Stream.map(fn n ->
      Integer.to_string(n)
      |> List.duplicate(count)
      |> Enum.join()
      |> String.to_integer()
    end)
  end
end

[file] = System.argv()
InvalidIDs.run(file)
