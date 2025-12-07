[file] = System.argv()

# Our only two operations are add and multiply.
# Thus, our tally will consist of 
#   - a sum (starting at 0)
#   - a product (starting with 1)
# and the final line will just choose which one we take.
initial = Stream.repeatedly(fn -> {0, 1} end)

File.stream!(file)
|> Enum.reduce(initial, fn line, tally ->
  line
  |> String.trim()
  |> String.split(~r/\s+/)
  |> Enum.zip_with(tally, fn
    "*", {_, product} ->
      product

    "+", {sum, _} ->
      sum

    number, {sum, product} when is_binary(number) ->
      number = String.to_integer(number)
      {sum + number, product * number}
  end)
end)
|> IO.inspect(label: "tally")
|> Enum.sum()
|> IO.inspect(label: "sum")
