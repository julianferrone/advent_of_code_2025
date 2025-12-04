defmodule Day3 do
  # _________________________ Part 1 _________________________

  # ---------------------- Parsing File ----------------------

  def part_1_answer(path) do
    with {:ok, binary} = File.read(path) do
      String.split(binary)
      |> Enum.map(fn line ->
        String.to_integer(line)
        |> Integer.digits()
        |> max_joltage1()
      end)
      |> Enum.sum()
    end
  end

  # ----------------------- Max Joltage ----------------------

  def max_joltage1([_head | rest] = line) do
    Enum.max([max_joltage_segment1(line), max_joltage1(rest)])
  end

  def max_joltage1(_line) do
    0
  end

  def max_joltage_segment1([head | rest] = segment) when length(segment) >= 2 do
    10 * head + Enum.max(rest)
  end

  def max_joltage_segment1(_segment) do
    0
  end

  # _________________________ Part 2 _________________________

  # ------------------------- File IO ------------------------

  def part_2_answer(path) do
    with {:ok, binary} = File.read(path) do
      String.split(binary)
      |> Enum.map(fn line ->
        parse_line(line)
        |> max_joltage2()
        |> digits_to_number()
      end)
      |> Enum.sum()
    end
  end

  def parse_line(line) do
    String.to_integer(line)
    |> Integer.digits()
  end

  # ----------------- Convert List to Number -----------------

  def digits_to_number(digits) do
    Enum.reduce(
      digits,
      0,
      fn digit, acc -> acc * 10 + digit end
    )
  end

  # ----------------------- Max Joltage ----------------------

  def max_joltage2(line, choices \\ 12) do
    max_size = length(line)

    candidates =
      Enum.with_index(
        line,
        # (index + choices - max_size) calculates the lowest candidate array
        # index you can insert the value at.

        #   (note: negative values doesn't mean "end of sequence", it means
        #    we can put the digits anywhere in the candidate array.)
        #   (Not that it would change the end-result (since we use the max
        #    operation) but we floor the negatives to zero to show
        #    that "the minimum index of these elements is zero" )
        fn element, index ->
          minimum_index = max(index + choices - max_size, 0)
          {element, minimum_index}
        end
      )
      |> Enum.reduce(
        %{
          current: List.duplicate(0, choices),
          previous_best: List.duplicate(0, choices)
        },
        fn {digit, minimum_index}, candidates ->
          index = Enum.find_index(candidates.current, fn d -> digit > d end)

          case index do
            nil ->
              candidates

            index ->
              index = max(index, minimum_index)
              previous_best = get_best_candidate(candidates)

              current =
                Enum.take(candidates.current, index) ++
                  [digit] ++ List.duplicate(0, choices - index - 1)

              %{
                previous_best: previous_best,
                current: current
              }
          end
        end
      )

    get_best_candidate(candidates)
  end

  def contains_zeroes(list) do
    Enum.any?(list, fn x -> x == 0 end)
  end

  def get_best_candidate(%{current: current, previous_best: previous_best}) do
    if contains_zeroes(current) do
      # Zeroes are placeholder values, so if current contains any,
      # it's not finished being filled in yet.
      previous_best
    else
      current
    end
  end
end
