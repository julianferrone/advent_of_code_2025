defmodule Day5Answer do
  @input_path Path.join(["inputs", "day_5.txt"])

  def say_part_1_answer do
    count = Day5.part_1_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 5 part 1 answer: #{count}")
  end

  def say_part_2_answer do
    sum = Day5.part_2_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 5 part 2 answer: #{sum}")
  end
end

Day5Answer.say_part_1_answer()
Day5Answer.say_part_2_answer()
