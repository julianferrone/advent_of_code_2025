defmodule Day8Answer do
  @input_path Path.join(["inputs", "day_8.txt"])

  def say_part_1_answer do
    count = Day8.part_1_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 8 part 1 answer: #{count}")
  end

  def say_part_2_answer do
    count = Day8.part_2_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 8 part 2 answer: #{count}")
  end
end

Day8Answer.say_part_1_answer()
Day8Answer.say_part_2_answer()
