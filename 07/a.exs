[file] = System.argv()

File.stream!(file)
|> Enum.reduce(:start, fn
  line, :start ->
    # First row: Create a beam wherever the "S" starting symbol is.
    [{col, _}] = Regex.run(~r/S/, line, return: :index)
    {0, MapSet.new([col])}

  line, {split_count, beams} ->
    # Subsequent rows: Find beams hitting splitters.
    splits =
      line
      |> String.trim()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn
        {"^", index} -> index in beams
        {".", _} -> false
      end)

    {
      split_count + Enum.count(splits),
      splits
      |> Enum.reduce(beams, fn {_, index}, beams ->
        beams
        |> MapSet.delete(index)
        |> MapSet.put(index - 1)
        |> MapSet.put(index + 1)
      end)
    }
end)
|> IO.inspect()
