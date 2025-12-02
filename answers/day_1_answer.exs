defmodule Day1Answer do
  @input_path Path.join(["inputs", "day_1.txt"])

  def say_part_1_answer do
    zeroes = Day1.part_1_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 1 part 1 answer: #{zeroes}")
  end

  def say_part_2_answer do
    zeroes = Day1.part_2_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 1 part 2 answer: #{zeroes}")
  end
end

Day1Answer.say_part_1_answer()
Day1Answer.say_part_2_answer()
