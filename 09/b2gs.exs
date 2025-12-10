defmodule BiggestRectangle2GS do
  defmodule MaxSize do
    use GenServer

    def start_link, do: GenServer.start_link(__MODULE__, nil)
    def get(pid), do: GenServer.call(pid, :get)

    def put(size, pid) do
      GenServer.cast(pid, {:put, size})
      size
    end

    @impl true
    def init(_), do: {:ok, 0}
    @impl true
    def handle_cast({:put, size}, max_size), do: {:noreply, max(max_size, size)}
    @impl true
    def handle_call(:get, _from, max_size), do: {:reply, max_size, max_size}
  end

  def run([file]) do
    red_tiles = parse_red_tiles(file)
    edges = find_edges(red_tiles)

    find_biggest(red_tiles, edges)
    |> io_inspect(label: "max")
  end

  defp parse_red_tiles(file) do
    File.stream!(file)
    |> Enum.map(fn line ->
      [x, y] =
        line
        |> String.trim()
        |> String.split(",", parts: 2)
        |> Enum.map(&String.to_integer/1)

      {x, y}
    end)
  end

  defp find_edges(red_tiles) do
    red_tiles
    |> Enum.zip_with(
      Stream.cycle(red_tiles) |> Stream.drop(1),
      fn
        {x, y1}, {x, y2} -> {x, min(y1, y2)..max(y1, y2)}
        {x1, y}, {x2, y} -> {min(x1, x2)..max(x1, x2), y}
      end
    )
  end

  defp find_biggest(red_tiles, edges) do
    {:ok, ms_pid} = MaxSize.start_link()

    red_tiles
    |> Enum.with_index()
    |> Task.async_stream(fn {red1, index} ->
      red_tiles
      |> Enum.drop(index + 1)
      |> Enum.reduce(MaxSize.get(ms_pid), fn red2, max_size ->
        size = rectangle_size(red1, red2)

        cond do
          size <= max_size -> max_size
          has_intrusions?(red1, red2, edges) -> max_size
          true -> size
        end
      end)
      |> MaxSize.put(ms_pid)
    end)
    |> Enum.map(fn {:ok, ms} -> ms end)
    |> io_inspect(label: "all max sizes", limit: :infinity)
    |> Enum.max()
  end

  defp has_intrusions?({rect_x1, rect_y1}, {rect_x2, rect_y2}, edges) do
    x_range = (min(rect_x1, rect_x2) + 1)..(max(rect_x1, rect_x2) - 1)//1
    y_range = (min(rect_y1, rect_y2) + 1)..(max(rect_y1, rect_y2) - 1)//1

    edges
    |> Enum.any?(fn
      {x, _.._//1 = yr} -> x in x_range && !Range.disjoint?(y_range, yr)
      {_.._//1 = xr, y} -> y in y_range && !Range.disjoint?(x_range, xr)
    end)
  end

  defp rectangle_size({x1, y1}, {x2, y2}) do
    (abs(x1 - x2) + 1) * (abs(y1 - y2) + 1)
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
  |> BiggestRectangle2GS.run()
end
