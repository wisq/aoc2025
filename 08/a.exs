defmodule JunctionBoxes do
  defmodule Circuits do
    def build(pairs) do
      pairs
      |> Enum.reduce(%{}, fn {id1, id2}, circuits ->
        circuits
        |> Enum.filter(fn {_, c} -> id1 in c || id2 in c end)
        |> then(fn
          [] ->
            # No circuit found for either id1 or id2 -- create a new one.
            circuits
            |> Map.put(id1, MapSet.new([id1, id2]))

          [{key, c}] ->
            # One of id1 or id2 is in a circuit already -- add to that one.
            circuits
            |> Map.replace!(key, c |> MapSet.put(id1) |> MapSet.put(id2))

          [{key1, c1}, {key2, c2}] ->
            # Both id1 and id2 are in different circuits -- merge them.
            circuits
            |> Map.replace!(key1, MapSet.union(c1, c2))
            |> Map.delete(key2)
        end)
      end)
    end

    def largest(circuits) do
      circuits
      |> Enum.map(fn {_key, c} -> Enum.count(c) end)
      |> Enum.sort(:desc)
    end
  end

  def run([count, file]) do
    count = String.to_integer(count)

    File.stream!(file)
    |> parse()
    |> connect_closest(count)
    |> Circuits.largest()
    |> io_inspect(label: "sizes")
    |> Enum.take(3)
    |> Enum.product()
    |> io_inspect(label: "product")
  end

  def parse(enum) do
    enum
    |> Enum.with_index()
    |> Enum.map(fn {line, id} ->
      [x, y, z] =
        line
        |> String.trim()
        |> String.split(",", parts: 3)
        |> Enum.map(&String.to_integer/1)

      {id, {x, y, z}}
    end)
  end

  def connect_closest(boxes, count) do
    all_distances(boxes)
    |> Enum.sort()
    |> Enum.take(count)
    |> Enum.map(fn {_dist, id1, id2} -> {id1, id2} end)
    |> Circuits.build()
  end

  defp all_distances(boxes) do
    boxes
    |> Enum.with_index()
    |> Enum.flat_map(fn {{id1, {x1, y1, z1}}, index} ->
      boxes
      |> Enum.drop(index + 1)
      |> Enum.map(fn {id2, {x2, y2, z2}} ->
        {
          :math.sqrt(
            (x1 - x2) ** 2 +
              (y1 - y2) ** 2 +
              (z1 - z2) ** 2
          ),
          id1,
          id2
        }
      end)
    end)
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
  |> JunctionBoxes.run()
end
