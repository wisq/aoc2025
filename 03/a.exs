[file] = System.argv()

File.stream!(file)
|> Enum.map(fn line ->
  batteries =
    line
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)

  {digit1, index1} =
    batteries
    # we can never use the last battery as the first digit
    |> Enum.drop(-1)
    |> Enum.with_index()
    # highest digit, lowest index
    |> Enum.min_by(fn {n, i} -> {-n, i} end)

  digit2 =
    batteries
    |> Enum.drop(index1 + 1)
    |> Enum.max()

  digit1 * 10 + digit2
end)
|> IO.inspect(charlists: :as_lists)
|> Enum.sum()
|> IO.inspect(label: "sum")
