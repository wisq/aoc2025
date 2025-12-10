defmodule Factory2 do
  def run([file]) do
    File.stream!(file)
    |> Enum.map(&parse_line/1)
    |> Enum.map(&solve/1)
    |> io_inspect()
    |> Enum.sum()
    |> io_inspect(label: "sum")
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
    |> Enum.reduce_while(MapSet.new([target]), fn press_count, old_states ->
      case MapSet.intersection(old_states, buttons) |> Enum.empty?() do
        false ->
          # Pressing one of the buttons now will zero out one of the states.
          # So we're done as of this button press.
          {:halt, press_count}

        true ->
          # More presses needed.
          old_states
          |> Enum.flat_map(fn st ->
            buttons
            |> Enum.map(&Bitwise.bxor(&1, st))
          end)
          |> MapSet.new()
          |> then(&{:cont, &1})
      end
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

  defp io_inspect(value, opts \\ []) do
    case Application.get_env(:aoc2025, :benchmarking, false) do
      true -> value
      false -> IO.inspect(value, opts)
    end
  end
end

unless Application.get_env(:aoc2025, :benchmarking) do
  System.argv()
  |> Factory2.run()
end
