defmodule Warehouse do
  @adjacent_coords for(row <- [-1, 0, 1], col <- [-1, 0, 1], do: {row, col})
                   |> List.delete({0, 0})

  @max_adjacent 3

  def run(file) do
    grid = build_grid(file)

    remove_all(grid)
    |> IO.inspect()
  end

  defp build_grid(file) do
    File.stream!(file)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, row} ->
      line
      |> String.trim()
      |> String.graphemes()
      |> Enum.map(fn
        "." -> false
        "@" -> true
      end)
      |> Enum.with_index()
      |> Enum.map(fn {value, col} ->
        {{row, col}, value}
      end)
    end)
    |> Map.new()
  end

  defp remove_all(grid) do
    new_coords =
      removable_coords(grid)
      |> Map.new(fn {coord, true} -> {coord, false} end)

    new_grid = grid |> Map.merge(new_coords)

    removed =
      Enum.count(new_coords)
      |> IO.inspect(label: "removed")

    if removed > 0 do
      removed + remove_all(new_grid)
    else
      removed
    end
  end

  defp removable_coords(grid) do
    grid
    |> Enum.filter(fn
      {_, false} -> false
      {coord, true} -> count_adjacent(coord, grid) <= @max_adjacent
    end)
  end

  defp count_adjacent({row, col}, grid) do
    @adjacent_coords
    |> Enum.count(fn {r, c} ->
      coord = {row + r, col + c}
      grid |> Map.get(coord)
    end)
  end
end

[file] = System.argv()
Warehouse.run(file)
