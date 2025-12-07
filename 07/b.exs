[file] = System.argv()

File.stream!(file)
|> Enum.reduce(:start, fn
  line, :start ->
    # First row: Create a single beam wherever the "S" starting symbol is.
    Regex.run(~r/S/, line, return: :index)
    |> then(fn [{index, 1}] -> %{index => 1} end)

  line, %{} = beams ->
    # Subsequent rows: For splitters hit by N beams, 
    #   add N more beams into each neighbouring space.
    Regex.scan(~r/\^/, line, return: :index)
    |> Enum.reduce(beams, fn [{index, 1}], beams ->
      {count, beams} = Map.pop(beams, index, 0)

      beams
      |> Map.update(index - 1, count, fn c -> c + count end)
      |> Map.update(index + 1, count, fn c -> c + count end)
    end)
end)
|> IO.inspect()
|> Map.values()
|> Enum.sum()
|> IO.inspect(label: "sum")
