[file] = System.argv()

File.stream!(file)
|> Enum.reduce({0, []}, fn line, {count, ranges} ->
  case line |> String.trim() |> String.split("-", parts: 2) do
    [min, max] ->
      min = String.to_integer(min)
      max = String.to_integer(max)
      ranges = [min..max | ranges]
      {count, ranges}

    [""] ->
      # section divider, ignore
      {count, ranges}

    [id] ->
      id = String.to_integer(id)

      case ranges |> Enum.any?(&(id in &1)) do
        true -> {count + 1, ranges}
        false -> {count, ranges}
      end
  end
end)
|> IO.inspect()

