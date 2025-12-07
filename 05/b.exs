defmodule Kitchen do
  def run(file) do
    read_ranges(file)
    |> Enum.reduce([], &add_range/2)
    |> IO.inspect()
    |> Enum.map(&Range.size/1)
    |> Enum.sum()
    |> IO.inspect(label: "sum")
  end

  defp read_ranges(file) do
    File.stream!(file)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, "-", parts: 2))
    |> Stream.take_while(fn
      [_, _] -> true
      [_] -> false
    end)
    |> Stream.map(fn [min, max] ->
      min = String.to_integer(min)
      max = String.to_integer(max)
      min..max
    end)
  end

  defp add_range(range, all_ranges) do
    {keep, to_merge} =
      all_ranges
      |> Enum.split_with(&Range.disjoint?(&1, range))
      |> IO.inspect(label: inspect(range))

    merged = merge_ranges([range | to_merge])
    [merged | keep]
  end

  defp merge_ranges(ranges) do
    min = ranges |> Enum.map(fn m.._//_ -> m end) |> Enum.min()
    max = ranges |> Enum.map(fn _..m//_ -> m end) |> Enum.max()
    min..max
  end
end

[file] = System.argv()
Kitchen.run(file)
