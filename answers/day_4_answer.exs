defmodule Day4Answer do
  @input_path Path.join(["inputs", "day_4.txt"])

  def say_part_1_answer do
    sum = Day4.part_1_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 3 part 1 answer: #{sum}")
  end

  def say_part_2_answer do
    sum = Day4.part_2_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 3 part 2 answer: #{sum}")
  end
end

Day4Answer.say_part_1_answer()
Day4Answer.say_part_2_answer()
