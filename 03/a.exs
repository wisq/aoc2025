[file] = System.argv()

File.stream!(file)
|> Enum.map(fn line ->
  batteries =
    line
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)

  batteries
  # we can never use the last battery as the first digit
  |> Enum.drop(-1)
  |> Enum.with_index()
  # highest digits first, lowest indices first
  |> Enum.sort_by(fn {n, i} -> {-n, i} end)
  |> Enum.reduce_while(0, fn {digit1, index}, best_joltage ->
    digit2 =
      batteries
      |> Enum.drop(index + 1)
      |> Enum.max()

    joltage = digit1 * 10 + digit2

    if joltage > best_joltage do
      IO.puts("#{best_joltage} -> #{joltage}")
      {:cont, joltage}
    else
      {:halt, best_joltage}
    end
  end)
end)
|> IO.inspect(charlists: :as_lists)
|> Enum.sum()
|> IO.inspect(label: "sum")
