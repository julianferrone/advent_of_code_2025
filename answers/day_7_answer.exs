defmodule Day7Answer do
  @input_path Path.join(["inputs", "day_7.txt"])

  def say_part_1_answer do
    count = Day7.part_1_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 7 part 1 answer: #{count}")
  end

  def say_part_2_answer do
    count = Day7.part_2_answer(@input_path) |> Integer.to_string()
    IO.puts("Day 7 part 2 answer: #{count}")
  end
end

Day7Answer.say_part_1_answer()
Day7Answer.say_part_2_answer()
