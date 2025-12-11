defmodule Paths do
  use Memoize

  def run([file]) do
    node_map =
      File.stream!(file)
      |> Enum.map(&parse_line/1)
      |> Map.new()
      |> io_inspect(label: "map")

    paths_to_out(:svr, node_map)
    |> elem(3)
    |> io_inspect(label: "via DAC and FFT")
  end

  defp parse_line(line) do
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

  # Returns a 4-tuple:
  #
  #   - number of paths that do not (yet) cross :dac or :fft
  #   - number of paths that cross :dac ONLY
  #   - number of paths that cross :fft ONLY
  #   - number of paths that cross BOTH :dac and :fft

  defmemop(paths_to_out(:out, _map), do: {1, 0, 0, 0})

  defmemop paths_to_out(:dac = node, map) do
    {naked, 0, fft, 0} = sum_paths(node, map)
    # Promote naked to DAC.
    # Promote FFT to DAC+FFT.
    {0, naked, 0, fft}
  end

  defmemop paths_to_out(:fft = node, map) do
    {naked, dac, 0, 0} = sum_paths(node, map)
    # Promote naked to FFT.
    # Promote DAC to DAC+FFT.
    {0, 0, naked, dac}
  end

  defmemop(paths_to_out(node, map), do: sum_paths(node, map))

  defp sum_paths(node, map) do
    map
    |> Map.fetch!(node)
    |> Enum.map(&paths_to_out(&1, map))
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.reduce(fn path, acc ->
      Enum.zip_with(path, acc, &Kernel.+/2)
    end)
    |> List.to_tuple()
    |> io_inspect(label: inspect(node))
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
