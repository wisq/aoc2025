Application.put_env(:aoc2025, :benchmarking, true)

{files, rest} =
  System.argv()
  |> Enum.split_while(fn
    "--" -> false
    _ -> true
  end)

args = rest |> Enum.drop(1)

files
|> Enum.map(fn file ->
  {module, _} = Code.require_file(file) |> Enum.at(-1)
  {file, fn -> module.run(args) end}
end)
|> Benchee.run()
