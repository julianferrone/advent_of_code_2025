defmodule Day1 do
  @dial_size 100

  defstruct pointer: 50

  alias __MODULE__, as: Dial

  @type t() :: %Dial{
          pointer: integer()
        }

  # _________________________ Part 1 _________________________

  def new() do
    %Dial{}
  end

  def new(pointer) do
    %Dial{pointer: pointer}
  end

  # ------------------------ Read Dial -----------------------

  def is_zero(%Dial{pointer: pointer}) do
    pointer == 0
  end

  # ----------------------- Change Dial ----------------------

  def left(%Dial{pointer: pointer} = dial, num) do
    %{dial | pointer: rem(pointer - num, @dial_size)}
  end

  def right(%Dial{pointer: pointer} = dial, num) do
    %{dial | pointer: rem(pointer + num, @dial_size)}
  end

  def apply_rotation(dial, {:left, distance}) do
    left(dial, distance)
  end

  def apply_rotation(dial, {:right, distance}) do
    right(dial, distance)
  end

  # --------------------- Parse Rotations --------------------

  def parse(<<"L", rest::binary>>) do
    {:left, String.to_integer(rest)}
  end

  def parse(<<"R", rest::binary>>) do
    {:right, String.to_integer(rest)}
  end

  # ------------------------- Answer -------------------------

  def part_1_answer(file) do
    {_dial, zeroes} =
      with {:ok, binary} = File.read(file) do
        Enum.reduce(
          String.split(binary),
          {new(), 0},
          fn line, {dial, zeroes} ->
            instruction = parse(line)
            dial = apply_rotation(dial, instruction)

            zeroes =
              if is_zero(dial) do
                zeroes + 1
              else
                zeroes
              end

            {dial, zeroes}
          end
        )
      end

    zeroes
  end

  # _________________________ Part 2 _________________________

  # ----------------------- Rotate Dial ----------------------

  def add_modulo(start, distance, modulus \\ @dial_size) do
    rotations = abs(div(distance, modulus))

    rest = rem(distance, modulus)

    intermediate = start + rest
    moduloed = Integer.mod(intermediate, modulus)

    cond do
      start == 0 -> {moduloed, rotations}
      intermediate <= 0 -> {moduloed, rotations + 1}
      intermediate >= modulus -> {moduloed, rotations + 1}
      true -> {intermediate, rotations}
    end
  end

  def rotate_count_zeroes(%Dial{pointer: pointer}, distance) do
    {moduloed, zeroes_count} = add_modulo(pointer, distance)
    dial = %Dial{pointer: moduloed}
    {dial, zeroes_count}
  end

  def apply_count_zeroes(dial, {:left, distance}) do
    rotate_count_zeroes(dial, -distance)
  end

  def apply_count_zeroes(dial, {:right, distance}) do
    rotate_count_zeroes(dial, distance)
  end

  # ------------------------- Answer -------------------------

  def part_2_answer(file) do
    {_dial, zeroes} =
      with {:ok, binary} = File.read(file) do
        Enum.reduce(
          String.split(binary),
          {new(), 0},
          fn line, {dial, zeroes} ->
            instruction = parse(line)
            {dial, extra_zeroes} = apply_count_zeroes(dial, instruction)

            {dial, zeroes + extra_zeroes}
          end
        )
      end

    zeroes
  end
end
