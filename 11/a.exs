defmodule Paths do
  def run([file]) do
    node_map =
      File.stream!(file)
      |> Enum.map(&parse_line/1)
      |> Map.new()
      |> io_inspect(label: "map")

    paths_to_out(:you, node_map)
    |> io_inspect(label: "paths")
  end

  def parse_line(line) do
    [node, conns] =
      line
      |> String.trim()
      |> String.split(": ", parts: 2)

    node = String.to_atom(node)

    conns =
      conns
      |> String.split(" ")
      |> Enum.map(&String.to_atom/1)

    {node, conns}
  end

  def paths_to_out(:out, _map), do: 1

  def paths_to_out(node, map) do
    map
    |> Map.fetch!(node)
    |> Enum.sum_by(&paths_to_out(&1, map))
  end

  defp io_inspect(value, opts) do
    case Application.get_env(:aoc2025, :benchmarking, false) do
      true -> value
      false -> IO.inspect(value, opts)
    end
  end
end

unless Application.get_env(:aoc2025, :benchmarking) do
  System.argv()
  |> Paths.run()
end
