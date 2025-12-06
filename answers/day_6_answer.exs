defmodule Day6Answer do
  @input_path Path.join(["inputs", "day_6.txt"])

  def say_part_1_answer do
    sum = Day6.part_1_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 6 part 1 answer: #{sum}")
  end

  def say_part_2_answer do
    sum = Day6.part_2_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 6 part 2 answer: #{sum}")
  end
end

Day6Answer.say_part_1_answer()
Day6Answer.say_part_2_answer()
