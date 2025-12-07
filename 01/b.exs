defmodule Dial do
  @initial {50, 0}

  def run(enum) do
    Enum.reduce(enum, @initial, &parse/2)
  end

  def parse(<<dir, rest::binary>>, state) do
    amount =
      rest
      |> String.trim()
      |> String.to_integer()

    case dir do
      ?L -> spin_left(amount, state)
      ?R -> spin_right(amount, state)
    end
    |> IO.inspect(label: <<dir>> <> String.pad_leading("#{amount}", 2, "0"))
    |> then(fn {p, z} when p in 0..99 -> {p, z} end)
  end

  def spin_left(amount, {0, zeros}) do
    (100 - amount)
    |> constrain_left(zeros)
  end

  def spin_left(amount, {pos, zeros}) do
    (pos - amount)
    |> constrain_left(zeros)
  end

  def constrain_left(0, z), do: {0, z + 1}
  def constrain_left(p, z) when p in 1..99, do: {p, z}
  def constrain_left(p, z) when p in -1..-99, do: {100 + p, z + 1}
  def constrain_left(p, z) when p < 0, do: constrain_left(rem(p, -100), z + div(p, -100))

  def spin_right(amount, {pos, zeros}) do
    (pos + amount)
    |> constrain_right(zeros)
  end

  def constrain_right(p, z) when p in 1..99, do: {p, z}
  def constrain_right(p, z) when p >= 100, do: {rem(p, 100), z + div(p, 100)}
end

[file] = System.argv()

File.stream!(file)
|> Dial.run()
|> IO.inspect()
