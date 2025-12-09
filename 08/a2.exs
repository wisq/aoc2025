defmodule JunctionBoxes2 do
  def run([count, file]) do
    count = String.to_integer(count)

    File.stream!(file)
    |> parse()
    |> closest_connection_map(count)
    |> build_circuits()
    |> Enum.map(&MapSet.size/1)
    |> Enum.sort(:desc)
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

  def closest_connection_map(boxes, count) do
    all_distances(boxes)
    |> Enum.sort()
    |> Enum.take(count)
    |> Enum.flat_map(fn {_dist, id1, id2} ->
      [{id1, id2}, {id2, id1}]
    end)
    |> Enum.group_by(fn {id, _} -> id end)
    |> Map.new(fn {id, conns} ->
      {id,
       conns
       |> Enum.map(fn
         {^id, other} -> other
         {other, ^id} -> other
       end)}
    end)
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

  def build_circuits(conn_map) do
    conn_map
    |> Map.keys()
    |> Enum.map_reduce(MapSet.new(), fn id, all_circuits ->
      if id in all_circuits do
        {nil, all_circuits}
      else
        circuit = walk_circuit(id, conn_map, MapSet.new())
        all_circuits = MapSet.union(all_circuits, circuit)
        {circuit, all_circuits}
      end
    end)
    |> elem(0)
    |> Enum.reject(&is_nil/1)
  end

  defp walk_circuit(from_id, conn_map, circuit) do
    io_inspect(from_id, label: "walking")

    circuit = circuit |> MapSet.put(from_id)

    Map.fetch!(conn_map, from_id)
    |> Enum.reduce(circuit, fn to_id, ct ->
      case to_id in ct do
        true -> ct
        false -> walk_circuit(to_id, conn_map, ct)
      end
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
  |> JunctionBoxes2.run()
end
