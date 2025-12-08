defmodule JunctionBoxes do
  defmodule Circuits do
    def build_until(pairs, box_count) do
      pairs
      |> Enum.reduce_while(%{}, fn {id1, id2}, circuits ->
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
        |> then(fn cs ->
          Map.values(cs)
          |> Enum.at(0)
          |> MapSet.size()
          |> then(fn count ->
            if count == box_count do
              {:halt, {id1, id2}}
            else
              {:cont, cs}
            end
          end)
        end)
      end)
    end
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

  def find_final_connection(boxes) do
    count = Enum.count(boxes)

    {id1, id2} =
      all_distances(boxes)
      |> Enum.sort()
      |> Enum.map(fn {_dist, id1, id2} -> {id1, id2} end)
      |> Circuits.build_until(count)

    boxes
    |> Enum.filter(fn {id, _} -> id == id1 || id == id2 end)
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
end

[file] = System.argv()

File.stream!(file)
|> JunctionBoxes.parse()
|> JunctionBoxes.find_final_connection()
|> IO.inspect(label: "final")
|> Enum.map(fn {_id, {x, _y, _z}} -> x end)
|> IO.inspect(label: "x coords")
|> Enum.product()
|> IO.inspect(label: "product")
