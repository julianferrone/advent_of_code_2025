defmodule Day2 do
  # _________________________ Part 1 _________________________

  # ---------------------- Parsing File ----------------------

  def split_file(contents) do
    String.split(contents, ",")
  end

  def parse_range(range) do
    [first, last] = String.split(range, "-")
    {first, ""} = Integer.parse(first)
    {last, ""} = Integer.parse(last)
    {first, last}
  end

  def parse_file(contents) do
    split_file(contents)
    |> Enum.map(&parse_range/1)
  end

  def invalid_range_sum({first, last}) do
    first..last
    |> Enum.reject(&validate_id/1)
    |> Enum.sum()
  end

  def invalid_file_sum(contents) do
    parse_file(contents)
    |> Enum.map(&invalid_range_sum/1)
    |> Enum.sum()
  end

  # ---------------------- ID Validation ---------------------

  def is_even(integer) do
    Integer.mod(integer, 2) == 0
  end

  def validate_id(id) do
    digits = Integer.digits(id)
    len = length(digits)

    if is_even(len) do
      {first_half, second_half} = Enum.split(digits, div(len, 2))
      first_half != second_half
      # Odd numbers can't be invalid
    else
      true
    end
  end

  # ------------------------- Answer -------------------------

  def part_1_answer(file) do
    with {:ok, binary} = File.read(file) do
      invalid_file_sum(binary)
    end
  end

  # _________________________ Part 2 _________________________

  # ---------------- Pattern Repetition Length ---------------

  def non_trivial_factors(number) when number >= 4 do
    2..div(number, 2)
    |> Enum.flat_map(fn factor_candidate ->
      if Integer.mod(number, factor_candidate) == 0 do
        factor2 = div(number, factor_candidate)
        [factor_candidate, factor2]
      else
        []
      end
    end)
    |> Enum.into(MapSet.new())
  end

  # 1, 2, and 3 have no non-trivial factors.
  def non_trivial_factors(_number), do: MapSet.new()

  # --------------- Check if Repeating Pattern ---------------

  def all_same?([]), do: true

  def all_same?([head | enumerable]) do
    Enum.map(
      enumerable,
      fn x -> head == x end
    )
    |> Enum.all?()
  end

  # ---------------------- ID Validation ---------------------

  def validate_id_2(id) do
    digits = Integer.digits(id)
    id_length = length(digits)

    if id_length >= 2 do
      pattern_lengths =
        id_length
        |> non_trivial_factors()
        # we also want to check for a pattern of one digit repeated
        |> MapSet.put(1)

      any_repetitions =
        Enum.map(
          pattern_lengths,
          fn length ->
            # Are all the chunks the same for a given chunk length?
            Enum.chunk_every(digits, length)
            |> all_same?()
          end
        )
        # Are there any repetitions?
        |> Enum.any?()

      not any_repetitions
    else
      true
    end
  end

  # --------------------- Sum Invalid IDs --------------------

  def invalid_range_sum_2({first, last}) do
    first..last
    |> Enum.reject(&validate_id_2/1)
    |> Enum.sum()
  end

  def invalid_file_sum_2(contents) do
    parse_file(contents)
    |> Enum.map(&invalid_range_sum_2/1)
    |> Enum.sum()
  end

  # ------------------------- Answer -------------------------

  def part_2_answer(file) do
    with {:ok, binary} = File.read(file) do
      invalid_file_sum_2(binary)
    end
  end
end
