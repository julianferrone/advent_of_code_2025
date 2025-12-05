defmodule Day5 do
  # _________________________ Part 1 _________________________

  # ---------------------- Parsing File ----------------------

  def parse_file(binary) do
    [ingredient_ranges, ingredient_ids] =
      binary
      # So that this solution will work in Unix and Windows environments
      |> String.replace("\r\n", "\n")
      |> String.split("\n\n")

    ingredient_ranges =
      String.split(ingredient_ranges)
      |> Enum.map(&parse_ingredient_id_range/1)

    ingredient_ids =
      String.split(ingredient_ids)
      |> Enum.map(&parse_ingredient_id/1)

    {ingredient_ranges, ingredient_ids}
  end

  def parse_ingredient_id_range(line) do
    [first, last] = String.split(line, "-")
    {first, ""} = Integer.parse(first)
    {last, ""} = Integer.parse(last)
    {first, last}
  end

  def parse_ingredient_id(line) do
    with {id, ""} <- Integer.parse(line) do
      id
    end
  end

  # -------------- Check if Ingredient is Fresh --------------

  def count_fresh1(ingredient_ranges, ingredient_ids) do
    Enum.count(ingredient_ids, fn id -> is_fresh(ingredient_ranges, id) end)
  end

  def within?({lower, upper}, id) do
    lower <= id and id <= upper
  end

  def is_fresh(ingredient_ranges, id) do
    Enum.any?(
      ingredient_ranges,
      fn range -> within?(range, id) end
    )
  end

  # ------------------------- Answer -------------------------

  def part_1_answer(path) do
    with {:ok, binary} = File.read(path) do
      {ingredient_ranges, ingredient_ids} = parse_file(binary)
      count_fresh1(ingredient_ranges, ingredient_ids)
    end
  end

  # ________________________ Part Two ________________________

  # --------------- Combine Overlapping Ranges ---------------

  def overlaps?({lower1, upper1} = range1, {lower2, upper2} = range2) do
    cond do
      # An endpoint is within the range of the other range
      within?(range1, lower2) -> true
      within?(range1, upper2) -> true
      within?(range2, lower1) -> true
      within?(range2, upper1) -> true
      true -> false
    end
  end

  def combine({lower1, upper1}, {lower2, upper2}) do
    {min(lower1, lower2), max(upper1, upper2)}
  end

  def combine_all(ranges) do
    ranges
    |> Enum.reduce(
      MapSet.new(),
      fn range, acc ->

        overlapping_range =
          Enum.find(
            acc,
            fn previous_range ->
              overlaps?(previous_range, range)
            end
          )

        case overlapping_range do
          nil ->
            MapSet.put(acc, range)

          _overlapping ->
            acc
            |> MapSet.delete(overlapping_range)
            |> MapSet.put(combine(range, overlapping_range))
        end
      end
    )
    |> Enum.into([])
  end

  def recurse_recombine_all(ranges) do
    recombined = combine_all(ranges)
    length_ranges = length(ranges)
    length_recombined = length(recombined)

    if length_ranges == length_recombined do
      recombined
    else
      recurse_recombine_all(recombined)
    end
  end

  # ----------------- Count Fresh Ingredients ----------------

  def count_fresh2(ingredient_ranges) do
    ingredient_ranges
    |> recurse_recombine_all()
    |> Enum.map(fn {lower, upper} -> upper - lower + 1 end)
    |> Enum.sum()
  end

  # ------------------------- Answer -------------------------

  def part_2_answer(path) do
    with {:ok, binary} = File.read(path) do
      {ingredient_ranges, _ingredient_ids} = parse_file(binary)
      count_fresh2(ingredient_ranges)
    end
  end
end
