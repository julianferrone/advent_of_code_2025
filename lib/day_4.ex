defmodule Day4 do
  # _________________________ Part 1 _________________________

  # ------------------------- Answer -------------------------

  def part_1_answer(path) do
    with {:ok, binary} = File.read(path) do
      parse_file(binary)
      |> count_accessible()
    end
  end

  # ---------------------- Parsing File ----------------------

  def parse_file(binary) do
    String.split(binary)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      Enum.map(
        parse_line(line),
        fn {parsed, x} -> {%{x: x, y: y}, parsed} end
      )
    end)
    |> Enum.into(Map.new())
  end

  def parse_line(line) do
    String.to_charlist(line)
    |> Enum.map(&parse_paper_char/1)
    # Indices are X values
    |> Enum.with_index()
  end

  def parse_paper_char(?@), do: :paper
  def parse_paper_char(?.), do: :empty

  # ----------------------- Adjacencies ----------------------

  def adjacent_positions(%{x: x, y: y}) do
    xs = Enum.filter([x - 1, x, x + 1], fn x -> x >= 0 end)
    ys = Enum.filter([y - 1, y, y + 1], fn y -> y >= 0 end)

    for adj_x <- xs,
        adj_y <- ys,
        adj_x != x or adj_y != y,
        do: %{x: adj_x, y: adj_y}
  end

  # -------------------- Accessible Paper --------------------

  def count_accessible(locations) do
    currently_accessible(locations)
    |> Enum.count()
  end

  # _________________________ Part 2 _________________________

  # _________________________ Answer _________________________

  def part_2_answer(path) do
    with {:ok, binary} = File.read(path) do
      parse_file(binary)
      |> remove_all_accessible()
    end
  end

  # -------------------- Accessible Paper --------------------

  def currently_accessible(locations) do
    Enum.flat_map(
      locations,
      fn {location, item} ->
        case item do
          :empty ->
            []

          :paper ->
            adjacent_positions = adjacent_positions(location)

            adjacent_paper =
              Enum.count(
                adjacent_positions,
                fn pos ->
                  Map.get(locations, pos) == :paper
                end
              )

            if adjacent_paper < 4 do
              [location]
            else
              []
            end
        end
      end
    )
  end

  def remove_accessible(locations) do
    can_remove = currently_accessible(locations)

    emptied =
      Enum.map(can_remove, fn location -> {location, :empty} end)
      |> Enum.into(Map.new())

    locations = Map.merge(locations, emptied)
    removed_count = length(can_remove)

    {locations, removed_count}
  end

  def remove_all_accessible(locations) do
    remove_all_accessible(locations, 0)
  end

  def remove_all_accessible(locations, removed_count) do
    {locations, newly_removed} = remove_accessible(locations)
    removed_count = removed_count + newly_removed

    case newly_removed do
      0 -> removed_count
      _n -> remove_all_accessible(locations, removed_count)
    end
  end
end
