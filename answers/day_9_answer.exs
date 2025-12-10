defmodule Day9Answer do
  @input_path Path.join(["inputs", "day_9.txt"])

  def say_part_1_answer do
    result = Day9.part_1_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 9 part 1 answer: #{result}")
  end

  def say_part_2_answer do
    result = Day9.part_2_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 9 part 2 answer: #{result}")
  end
end

Day9Answer.say_part_1_answer()
Day9Answer.say_part_2_answer()
