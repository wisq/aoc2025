defmodule Factory do
  def run([file]) do
    File.stream!(file)
    |> Enum.map(&parse_line/1)
    |> Enum.map(&solve/1)
    |> IO.inspect()
    |> Enum.sum()
    |> IO.inspect(label: "sum")
  end

  defp parse_line(line) do
    Regex.run(
      ~r/^
      \[([\.#]+)\]    # target value
      \s
      ([0-9,()\s]+)   # buttons
      \s
      {               # start of joltage (ignored) 
    /x,
      line
    )
    |> then(fn [_, target, buttons] ->
      {
        dothash_to_integer(target),
        parse_buttons(buttons)
      }
    end)
  end

  defp solve({target, buttons}) do
    1..100
    |> Enum.reduce_while(MapSet.new([0]), fn press_count, old_states ->
      old_states
      |> Enum.flat_map(fn st ->
        buttons
        |> Enum.map(&Bitwise.bxor(&1, st))
      end)
      |> MapSet.new()
      |> then(fn new_states ->
        case target in new_states do
          false -> {:cont, new_states}
          true -> {:halt, press_count}
        end
      end)
    end)
  end

  defp dothash_to_integer(dh) do
    dh
    |> String.replace(["#", "."], fn
      "#" -> "1"
      "." -> "0"
    end)
    |> String.reverse()
    |> String.to_integer(2)
  end

  defp parse_buttons(buttons) do
    buttons
    |> String.split()
    |> Enum.map(&parse_button/1)
    |> MapSet.new()
  end

  defp parse_button(button) do
    button
    |> String.trim_leading("(")
    |> String.trim_trailing(")")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&(2 ** &1))
    |> Enum.sum()
  end
end

System.argv()
|> Factory.run()
