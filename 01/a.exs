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

  pos =
    (pos + amount)
    |> rem(100)
    |> then(fn
      n when n < 0 -> 100 + n
      n when n >= 0 -> n
    end)

  zeros =
    case pos do
      0 -> zeros + 1
      _ -> zeros
    end

  {pos, zeros}
end)
|> IO.inspect()
