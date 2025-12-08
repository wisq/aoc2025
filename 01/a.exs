[file] = System.argv()

File.stream!(file)
|> Enum.reduce({50, 0}, fn <<dir, rest::binary>>, {pos, zeros} ->
  amount =
    rest
    |> String.trim()
    |> String.to_integer()
    |> then(fn a ->
      case dir do
        ?L -> -a
        ?R -> a
      end
    end)

  pos = (pos + amount) |> Integer.mod(100)

  zeros =
    case pos do
      0 -> zeros + 1
      _ -> zeros
    end

  {pos, zeros}
end)
|> IO.inspect()
