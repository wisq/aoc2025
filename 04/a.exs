[file] = System.argv()

adjacent_coords =
  for(row <- [-1, 0, 1], col <- [-1, 0, 1], do: {row, col})
  |> List.delete({0, 0})

grid =
  File.stream!(file)
  |> Enum.with_index()
  |> Enum.flat_map(fn {line, row} ->
    line
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(fn
      "." -> false
      "@" -> true
    end)
    |> Enum.with_index()
    |> Enum.map(fn {value, col} ->
      {{row, col}, value}
    end)
  end)
  |> Map.new()

grid
|> Enum.sort()
|> Enum.count(fn
  {_, false} ->
    false

  {{row, col}, value} ->
    adjacent_coords
    |> Enum.count(fn {r, c} ->
      coord = {row + r, col + c}
      grid |> Map.get(coord)
    end)
    |> IO.inspect(label: "adjacent to " <> inspect({row, col}))
    |> then(&(&1 < 4))
end)
|> IO.inspect()
