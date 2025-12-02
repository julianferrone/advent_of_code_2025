defmodule Day1Test do
  use ExUnit.Case
  doctest AdventOfCode2025

  test "counts hitting exactly zero via right exactly once" do
    dial = Day1.new(50)

    {dial, zeroes} = Day1.apply_count_zeroes(dial, {:right, 50})

    assert zeroes == 1
    assert dial.pointer == 0
  end

  test "counts hitting exactly zero via left exactly once" do
    dial = Day1.new(50)

    {dial, zeroes} = Day1.apply_count_zeroes(dial, {:left, 50})

    assert zeroes == 1
    assert dial.pointer == 0
  end

  test "counts hitting exactly zero via right exactly twice" do
    dial = Day1.new(50)

    {dial, zeroes} = Day1.apply_count_zeroes(dial, {:right, 150})

    assert zeroes == 2
    assert dial.pointer == 0
  end

  test "counts hitting exactly zero via left exactly twice" do
    dial = Day1.new(50)

    {dial, zeroes} = Day1.apply_count_zeroes(dial, {:left, 150})

    assert zeroes == 2
    assert dial.pointer == 0
  end

  test "going right from zero counts no zeroes" do
    dial = Day1.new(0)

    {dial, zeroes} = Day1.apply_count_zeroes(dial, {:right, 10})

    assert zeroes == 0
    assert dial.pointer == 10
  end

  test "going left from zero counts no zeroes" do
    dial = Day1.new(0)

    {dial, zeroes} = Day1.apply_count_zeroes(dial, {:left, 10})

    assert zeroes == 0
    assert dial.pointer == 90
  end
end
