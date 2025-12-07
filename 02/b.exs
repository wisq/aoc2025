defmodule InvalidIDs do
  def run(file) do
    File.read!(file)
    |> String.split(",")
    |> Enum.map(&parse_range/1)
    |> Enum.map(fn range -> {range, find_invalid(range)} end)
    |> IO.inspect(limit: :infinity)
    |> Enum.map(fn {_, ids} -> Enum.sum(ids) end)
    |> Enum.sum()
    |> IO.inspect(label: "sum")
  end

  defp parse_range(line) do
    [min, max] =
      line
      |> String.trim()
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    min..max
  end

  defp find_invalid(min..max//_) do
    possible_slices(max)
    |> IO.inspect(label: "#{min}..#{max} slices")
    |> Enum.flat_map(fn {count, size} ->
      leading_digits(min, count, size)
      |> invalid_id_stream(count)
      |> Stream.drop_while(fn n -> n < min end)
      |> Stream.take_while(fn n -> n <= max end)
      |> Stream.each(fn n -> IO.inspect(n, label: "#{min}..#{max} #{count}x#{size}") end)
    end)
    |> Enum.uniq()
  end

  # What ways can we slice up a number into digit groups?
  #
  # 123456 -> [{2, 3}, {3, 2}, {4, 1}, {5, 1}, {6, 1}]
  #   - 2x3 digits, e.g. 100100, 101101, 102102, ...
  #   - 3x2 digits, e.g. 101010, 111111, 121212, ...
  #   - 4x1 digits, e.g. 1111, 2222, 3333, ...
  #   - 5x1 digits, e.g. 11111, 22222, 33333, ...
  #   - 6x1 digits, e.g. 111111, 222222, 333333, ...
  #
  # Note that some combinations won't make any sense --
  # like if you're testing a range of 99999 to 123456,
  # then obviously we don't care about 4x1.
  #
  # But that's fine, since at just ten cycles,
  # our 4x1 tests will go from 9999 to 10101010,
  # which is too high and will stop the 4x1 scan.
  #
  # (It's worth noting that `size` is just the START size --
  #  per above, our 4x1 will eventually turn into a 4x2,
  #  but as long as our start number has at least 4 digits,
  #  we'll start with that first digit repeated 4x times
  #  since the first invalid can't be any lower than that.)
  defp possible_slices(num) do
    str = Integer.to_string(num)
    len = String.length(str)

    1..len
    |> Enum.map(fn size ->
      {size, div(len, size)}
    end)
    |> Enum.filter(fn {count, size} -> count > 1 && size > 0 end)
  end

  # Get `size` digits from `num`, assuming `count` groups.
  #
  # If `num` has at least `size*count` digits,
  # this will be the first `size` digits.
  #
  # Otherwise, this will be a power of ten with `size` digits.
  # For a size of 3, that would be 100, because e.g. the lowest
  # possible 3x3 invalid ID would be 100100100.
  defp leading_digits(num, count, size) do
    str = Integer.to_string(num)

    if count * size > String.length(str) do
      10 ** (size - 1)
    else
      str
      |> String.slice(0, size)
      |> String.to_integer()
    end
  end

  # Given e.g. start = 123 and count = 2,
  # will generate a stream of [123123, 124124, 125125, ...]
  #
  # or start = 45 and count = 5,
  # will generate an infinite stream of [4545454545, 4646464646, 4747474747, ...]
  defp invalid_id_stream(start, count) do
    Stream.iterate(start, &(&1 + 1))
    |> Stream.map(fn n ->
      Integer.to_string(n)
      |> List.duplicate(count)
      |> Enum.join()
      |> String.to_integer()
    end)
  end
end

[file] = System.argv()
InvalidIDs.run(file)
