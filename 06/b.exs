defmodule SquidMath do
  def run([file]) do
    # Our only two operations are add and multiply.
    # Thus, our tally will consist of 
    #   - a sum (starting at 0)
    #   - a product (starting with 1)
    # and the final line will just choose which one we take.
    initial = {0, 1}

    File.stream!(file)
    |> Enum.map(fn line ->
      line
      |> :string.chomp()
      |> String.graphemes()
    end)
    # transpose
    |> Enum.zip_with(&Function.identity/1)
    # start from the rightmost column (now the bottom row)
    |> Enum.reverse()
    |> Enum.reduce({0, initial}, fn row, {total, {sum, product}} ->
      {operation, digits} = List.pop_at(row, -1)
      number = Enum.join(digits) |> String.trim()

      {sum, product} =
        case number do
          "" ->
            # No number, blank row.  Reset the tally.
            initial

          n when is_binary(n) ->
            number = String.to_integer(number)
            {sum + number, product * number}
        end

      total =
        case operation do
          "*" -> total + product
          "+" -> total + sum
          " " -> total
        end

      {total, {sum, product}}
    end)
    |> elem(0)
    |> io_inspect(label: "sum")
  end

  def io_inspect(value, opts \\ []) do
    case Application.get_env(:aoc2025, :benchmarking, false) do
      true -> value
      false -> IO.inspect(value, opts)
    end
  end
end

unless Application.get_env(:aoc2025, :benchmarking) do
  System.argv()
  |> SquidMath.run()
end
