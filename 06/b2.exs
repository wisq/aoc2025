[filename] = System.argv()
file = File.open!(filename, [:binary, :read])

line_length = IO.read(file, :line) |> byte_size()
{:ok, file_size} = :file.position(file, {:eof, 0})

# This both calculates a list of offsets for each line,
# and also does a sanity check to ensure the math works out —
# there should be one last "fake" line offset at EOF.
{line_offsets, [^file_size]} =
  0..file_size//line_length
  |> Enum.split(-1)

{:ok, last_line} = :file.pread(file, Enum.at(line_offsets, -1), line_length - 1)

Regex.scan(~r/([\*\+]\s*)(?:\s|$)/, last_line, return: :index)
|> Enum.map(fn [{_, _}, {offset, size}] ->
  # For each line in the file, extract the portion that corresponds to our problem area.  
  # The last line will contain just the operator plus whitespace.
  {number_lines, [[operator | _]]} =
    line_offsets
    |> Enum.map(fn start ->
      {:ok, nstr} = :file.pread(file, start + offset, size)
      String.graphemes(nstr)
    end)
    |> Enum.split(-1)

  function =
    case operator do
      "*" -> &Enum.product/1
      "+" -> &Enum.sum/1
    end

  number_lines
  # Transpose and extract numbers from each column.
  |> Enum.zip_with(fn digits ->
    digits
    |> Enum.join()
    |> String.trim()
    |> String.to_integer()
  end)
  # Apply the operator function, above.
  |> then(function)
end)
|> IO.inspect()
|> Enum.sum()
|> IO.inspect(label: "sum")
