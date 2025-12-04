defmodule Day2Answer do
  @input_path Path.join(["inputs", "day_2.txt"])

  def say_part_1_answer do
    sum = Day2.part_1_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 1 part 1 answer: #{sum}")
  end

  def say_part_2_answer do
    sum = Day2.part_2_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 1 part 2 answer: #{sum}")
  end
end

Day2Answer.say_part_1_answer()
Day2Answer.say_part_2_answer()
