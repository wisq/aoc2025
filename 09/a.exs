[file] = System.argv()

red_tiles =
  File.stream!(file)
  |> Enum.map(fn line ->
    [x, y] =
      line
      |> String.trim()
      |> String.split(",", parts: 2)
      |> Enum.map(&String.to_integer/1)

    {x, y}
  end)

red_tiles
|> Enum.with_index()
|> Enum.reduce(0, fn {{x1, y1}, index}, max_size ->
  red_tiles
  |> Enum.drop(index + 1)
  |> Enum.reduce(0, fn {x2, y2}, ms ->
    ms |> max((abs(x1 - x2) + 1) * (abs(y1 - y2) + 1))
  end)
  |> max(max_size)
end)
|> IO.inspect(label: "max")
