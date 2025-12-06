defmodule Day6 do
  # _________________________ Part 1 _________________________

  # ---------------------- Parsing File ----------------------

  def parse_file1(binary) do
    lines =
      binary
      # So that this solution will work in Unix and Windows environments
      |> String.replace("\r\n", "\n")
      |> String.split("\n")

    {number_lines, lines} = Enum.split(lines, 4)

    number_lines =
      Enum.map(number_lines, &parse_numbers1/1)

    argument_lines =
      Enum.take(lines, 1)
      |> Enum.map(&parse_operators1/1)

    # This should create a tuple of form {arg, num1, num2, num3, num4}
    Enum.zip(argument_lines ++ number_lines)
  end

  def parse_numbers1(line) do
    String.split(line)
    |> Enum.map(fn entry ->
      with {number, ""} = Integer.parse(entry) do
        number
      end
    end)
  end

  def parse_operators1(line) do
    String.split(line)
    |> Enum.map(fn entry ->
      case entry do
        "*" -> :product
        "+" -> :sum
      end
    end)
  end

  # ------------------- Applying Operations ------------------

  def apply1({:sum, x1, x2, x3, x4}) do
    Enum.sum([x1, x2, x3, x4])
  end

  def apply1({:product, x1, x2, x3, x4}) do
    Enum.product([x1, x2, x3, x4])
  end

  # ------------------------- Answer -------------------------

  def part_1_answer(path) do
    with {:ok, binary} = File.read(path) do
      parse_file1(binary)
      |> Enum.map(&apply1/1)
      |> Enum.sum()
    end
  end

  # _________________________ Part 2 _________________________

  # ----------------------- Parse File -----------------------

  def parse_file2(binary) do
    lines =
      binary
      # So that this solution will work in Unix and Windows environments
      |> String.replace("\r\n", "\n")
      |> String.split("\n")

    {number_lines, lines} = Enum.split(lines, 4)

    number_lines = parse_numbers2(number_lines)
    argument_line = parse_operators2(List.first(lines))

    # This should create a tuple of form {arg, num1, num2, num3, num4}
    Enum.zip(argument_line, number_lines)
  end

  # --------------------- Parse Operators --------------------

  def parse_operators2(line) do
    String.split(line)
    |> Enum.map(fn entry ->
      case entry do
        "*" -> :product
        "+" -> :sum
      end
    end)
    |> Enum.reverse()
  end

  # ------------------ Parse Number Columns ------------------

  def parse_numbers2(lines) do
    lines = List.to_tuple(lines)

    parse_numbers2(lines, [], [])
  end

  def parse_numbers2(lines, all_problems, current_problem) do
    case parse_number_column(lines) do
      {:group_end, lines} ->
        parse_numbers2(lines, [current_problem | all_problems], [])

      {:number, number, lines} ->
        parse_numbers2(lines, all_problems, [number | current_problem])

      :end ->
        [current_problem | all_problems]
    end
  end

  # ...................... Parse Columns .....................

  def parse_number_column({
        <<?\s, line1::binary>>,
        <<?\s, line2::binary>>,
        <<?\s, line3::binary>>,
        <<?\s, line4::binary>>
      }) do
    {:group_end, {line1, line2, line3, line4}}
  end

  def parse_number_column({
        <<d1, line1::binary>>,
        <<d2, line2::binary>>,
        <<d3, line3::binary>>,
        <<d4, line4::binary>>
      }) do
    digits =
      Enum.map(
        [[d1], [d2], [d3], [d4]],
        &to_string/1
      )

    {
      :number,
      column_to_integer(digits),
      {line1, line2, line3, line4}
    }
  end

  def parse_number_column({
        "",
        "",
        "",
        ""
      }) do
    :end
  end

  # ................... Convert to Integer ...................

  def column_to_integer(digits) do
    Enum.reject(digits, fn digit -> digit == " " end)
    |> Enum.join()
    |> String.to_integer()
  end

  # ------------------- Applying Operations ------------------

  def apply2({:sum, summands}), do: Enum.sum(summands)
  def apply2({:product, factors}), do: Enum.product(factors)

  # ------------------------- Answer -------------------------

  def part_2_answer(path) do
    with {:ok, binary} = File.read(path) do
      parse_file2(binary)
      |> Enum.map(&apply2/1)
      |> Enum.sum()
    end
  end
end
