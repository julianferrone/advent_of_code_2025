defmodule Day7 do
  # _________________________ Part 1 _________________________

  # ------------------------- Lexing -------------------------

  def lex(?.), do: nil
  def lex(?^), do: :splitter
  def lex(?S), do: :source

  # ----------------------- Parse File -----------------------

  def parse_line(line) do
    line
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.flat_map(fn {char, index} ->
      case lex(char) do
        nil -> []
        other -> [{other, index}]
      end
    end)
  end

  def parse_tachyon_manifold(binary) do
    lines =
      binary
      |> String.replace("\r\n", "\n")
      |> String.split("\n")

    max_height = length(lines)

    part_coords =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        Enum.map(
          parse_line(line),
          fn {part, x} -> {part, {x, y}} end
        )
      end)

    source = Keyword.get(part_coords, :source)
    splitters = MapSet.new(Keyword.get_values(part_coords, :splitter))
    %{source: source, splitters: splitters, max_height: max_height}
  end

  # --------------------- Counting Splits --------------------

  def splitter_at_coord?(tachyon_manifold, coord) do
    MapSet.member?(tachyon_manifold.splitters, coord)
  end

  def count_tachyon_splits(tachyon_manifold) do
    source_coord = tachyon_manifold.source
    {_x, initial_height} = source_coord

    count_tachyon_splits(
      tachyon_manifold,
      MapSet.new([source_coord]),
      0,
      initial_height
    )
  end

  def count_tachyon_splits(tachyon_manifold, beam_coord_set, split_count, height) do
    next_height = height + 1

    if next_height >= tachyon_manifold.max_height do
      split_count
    else
      next_step = Enum.map(beam_coord_set, fn {x, y} -> {x, y + 1} end)

      {next_beam_set, current_split_count} =
        Enum.flat_map_reduce(
          next_step,
          0,
          fn coord, count ->
            if splitter_at_coord?(tachyon_manifold, coord) do
              {split_tachyon_beam(coord), count + 1}
            else
              {[coord], count}
            end
          end
        )

      next_beam_set = Enum.into(next_beam_set, MapSet.new())

      count_tachyon_splits(
        tachyon_manifold,
        next_beam_set,
        split_count + current_split_count,
        next_height
      )
    end
  end

  def split_tachyon_beam({x, y}) do
    [
      # Left beam
      {x - 1, y},
      # Right beam
      {x + 1, y}
    ]
  end

  def split_tachyon_beam({x, y}, count) do
    Map.new([
      # Left beam
      {{x - 1, y}, count},
      # Right beam
      {{x + 1, y}, count}
    ])
  end

  # ------------------------- Answer -------------------------

  def part_1_answer(path) do
    with {:ok, binary} = File.read(path) do
      parse_tachyon_manifold(binary)
      |> count_tachyon_splits()
    end
  end

  # _________________________ Part 2 _________________________

  # --------------------- Count Timelines --------------------

  def count_tachyon_timelines(tachyon_manifold) do
    source_coord = tachyon_manifold.source
    {_x, initial_height} = source_coord

    count_tachyon_timelines(
      tachyon_manifold,
      %{source_coord => 1},
      initial_height
    )
  end

  def count_tachyon_timelines(tachyon_manifold, beam_coords, height) do
    next_height = height + 1

    if next_height >= tachyon_manifold.max_height do
      Map.values(beam_coords) |> Enum.sum()
    else
      next_step =
        Enum.map(beam_coords, fn {{x, y}, count} -> {{x, y + 1}, count} end)
        |> Enum.into(Map.new())

      next_beams =
        Enum.reduce(
          next_step,
          Map.new(),
          fn {coord, count}, acc ->
            next_coords =
              if splitter_at_coord?(tachyon_manifold, coord) do
                split_tachyon_beam(coord, count)
              else
                Map.new() |> Map.put(coord, count)
              end

            Map.merge(acc, next_coords, fn _k, count, existing_count ->
              existing_count + count
            end)
          end
        )

      count_tachyon_timelines(
        tachyon_manifold,
        next_beams,
        next_height
      )
    end
  end

  # ------------------------- Answer -------------------------

  def part_2_answer(path) do
    with {:ok, binary} = File.read(path) do
      parse_tachyon_manifold(binary)
      |> count_tachyon_timelines()
    end
  end
end
