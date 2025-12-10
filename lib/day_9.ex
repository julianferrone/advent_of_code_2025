defmodule Day9 do
  # _________________________ Part 1 _________________________

  # -------------------------- Types -------------------------

  @type point :: %{x: integer(), y: integer()}
  @type line :: %{start: point(), finish: point()}
  @type rectangle :: %{bottom_left: point(), top_right: point()}

  @spec new_point(integer(), integer()) :: point()
  def new_point(x, y), do: %{x: x, y: y}

  @spec new_line(point(), point()) :: line()
  def new_line(start, finish), do: %{start: start, finish: finish}

  @spec new_rectangle(point(), point()) :: rectangle()
  def new_rectangle(point1, point2) do
    {left, right} = Enum.min_max([point1.x, point2.x])
    {bottom, top} = Enum.min_max([point1.y, point2.y])

    %{
      bottom_left: new_point(left, bottom),
      top_right: new_point(right, top)
    }
  end

  # ---------------------- Parsing File ----------------------

  @spec parse_tile(String.t()) :: point()
  def parse_tile(line) do
    [x, y] =
      String.split(line, ",", parts: 2)
      |> Enum.map(&String.to_integer/1)

    new_point(x, y)
  end

  @spec parse_tile(String.t()) :: list(point())
  def parse_file(binary) do
    binary
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> Enum.reject(fn s -> s == "" end)
    |> Enum.map(&parse_tile/1)
  end

  # ---------------------- Combinations ----------------------

  @spec pair_combos(list(term())) :: list({term(), term()})
  def pair_combos(enumerable) do
    {pairs, _seen} =
      Enum.flat_map_reduce(
        enumerable,
        [],
        fn element, seen ->
          pairs = Enum.map(seen, fn seen_element -> {seen_element, element} end)
          seen = [element | seen]
          {pairs, seen}
        end
      )

    pairs
  end

  # --------------------- Calculate Area ---------------------

  @spec rectangle_area(rectangle()) :: integer()
  def rectangle_area(rectangle) do
    rectangle_area(rectangle.bottom_left, rectangle.top_right)
  end

  @spec rectangle_area(point(), point()) :: integer()
  def rectangle_area(tile1, tile2) do
    x_diff = abs(tile1.x - tile2.x) + 1
    y_diff = abs(tile1.y - tile2.y) + 1
    x_diff * y_diff
  end

  # -------------------- Largest Rectangle -------------------

  @spec largest_rectangle1(list(point())) :: rectangle()
  def largest_rectangle1(tiles) do
    pair_combos(tiles)
    |> Enum.map(fn {tile1, tile2} -> new_rectangle(tile1, tile2) end)
    |> Enum.max_by(&rectangle_area/1)
  end

  # ------------------------- Answer -------------------------

  @spec part_1_answer(Path.t()) :: integer()
  def part_1_answer(path) do
    with {:ok, binary} = File.read(path) do
      parse_file(binary)
      |> largest_rectangle1()
      |> rectangle_area()
    end
  end

  # _________________________ Part 2 _________________________

  # --------------------- Bounding Coords --------------------

  @spec bound_top(rectangle() | line()) :: integer()
  def bound_top(%{top_right: top_right}), do: top_right.y

  def bound_top(%{start: start, finish: finish}) do
    max(start.y, finish.y)
  end

  @spec bound_bottom(rectangle() | line()) :: integer()
  def bound_bottom(%{bottom_left: bottom_left}), do: bottom_left.y

  def bound_bottom(%{start: start, finish: finish}) do
    min(start.y, finish.y)
  end

  @spec bound_left(rectangle() | line()) :: integer()
  def bound_left(%{bottom_left: bottom_left}), do: bottom_left.x

  def bound_left(%{start: start, finish: finish}) do
    min(start.x, finish.x)
  end

  @spec bound_right(rectangle() | line()) :: integer()
  def bound_right(%{top_right: top_right}), do: top_right.x

  def bound_right(%{start: start, finish: finish}) do
    max(start.x, finish.x)
  end

  # ---------------- Rectangle / Line Overlap ----------------

  @spec within?(term(), term(), term()) :: boolean()
  def within?(x, lower, upper) do
    lower <= x and x <= upper
  end

  @spec rect_contains?(rectangle(), point()) :: boolean()
  def rect_contains?(rectangle, point) do
    Enum.all?([
      within?(point.x, rectangle.bottom_left.x, rectangle.top_right.x),
      within?(point.y, rectangle.bottom_left.y, rectangle.top_right.y)
    ])
  end

  @spec rect_overlaps?(rectangle(), line()) :: boolean()
  def rect_overlaps?(rectangle, line) do
    orientation = line_orientation(line)

    Enum.any?([
      # Rectangle contains an endpoint of the line
      rect_contains?(rectangle, line.start),
      rect_contains?(rectangle, line.finish),
      # Endpoints are outside the rectangle but line overlaps anyways
      Enum.all?([
        orientation == :vertical,
        bound_top(rectangle) <= bound_top(line),
        bound_bottom(line) <= bound_bottom(rectangle),
        within?(line.start.x, bound_left(rectangle), bound_right(rectangle))
      ]),
      Enum.all?([
        orientation == :horizontal,
        bound_left(line) <= bound_left(rectangle),
        bound_right(rectangle) <= bound_right(line),
        within?(line.start.y, bound_bottom(rectangle), bound_top(rectangle))
      ])
    ])
  end

  # ------------------- Cardinal Directions ------------------

  @type orthogonal() :: :up | :down | :left | :right
  @type diagonal() :: :up_left | :up_right | :down_left | :down_right
  @type direction() :: orthogonal() | diagonal()
  @type orientation() :: :vertical | :horizontal

  @spec line_direction(line()) :: orthogonal()
  def line_direction(line) do
    line_direction(line.start, line.finish)
  end

  @spec line_direction(point(), point()) :: orthogonal()
  def line_direction(start, finish) do
    cond do
      start.y < finish.y -> :up
      start.y > finish.y -> :down
      start.x < finish.x -> :right
      start.x > finish.x -> :left
    end
  end

  @spec line_orientation(line()) :: orientation()
  def line_orientation(line) do
    case line_direction(line) do
      :up -> :vertical
      :down -> :vertical
      :left -> :horizontal
      :right -> :horizontal
    end
  end

  @spec shift_point(point(), direction()) :: point()
  def shift_point(point, :up), do: %{point | y: point.y + 1}
  def shift_point(point, :down), do: %{point | y: point.y - 1}
  def shift_point(point, :left), do: %{point | x: point.x - 1}
  def shift_point(point, :right), do: %{point | x: point.x + 1}

  def shift_point(point, :up_left) do
    point |> shift_point(:up) |> shift_point(:left)
  end

  def shift_point(point, :up_right) do
    point |> shift_point(:up) |> shift_point(:right)
  end

  def shift_point(point, :down_left) do
    point |> shift_point(:down) |> shift_point(:left)
  end

  def shift_point(point, :down_right) do
    point |> shift_point(:down) |> shift_point(:right)
  end

  # ------------------------ Rotations -----------------------

  @type rotation() :: :clockwise | :counterclockwise

  @spec change_direction(orthogonal(), orthogonal()) :: rotation()
  def change_direction(:up, :right), do: :clockwise
  def change_direction(:up, :left), do: :counterclockwise

  def change_direction(:down, :left), do: :clockwise
  def change_direction(:down, :right), do: :counterclockwise

  def change_direction(:left, :up), do: :clockwise
  def change_direction(:left, :down), do: :counterclockwise

  def change_direction(:right, :down), do: :clockwise
  def change_direction(:right, :up), do: :counterclockwise

  # ------------------- Red Tile Path Edges ------------------

  @type edges() :: %{left_edge: line(), right_edge: line()}

  def new_edges(left_edge, right_edge) do
    %{left_edge: left_edge, right_edge: right_edge}
  end

  @spec bordering_edges(line()) :: edges()
  def bordering_edges(line) do
    direction = line_direction(line)

    {
      shift_left_start,
      shift_left_finish,
      shift_right_start,
      shift_right_finish
    } =
      case direction do
        :left ->
          {:down_left, :down_right, :up_left, :up_right}

        :right ->
          {:up_right, :up_left, :down_right, :down_left}

        :up ->
          {:up_left, :down_left, :up_right, :down_right}

        :down ->
          {:down_right, :up_right, :down_left, :up_left}
      end

    new_edges(
      new_line(
        shift_point(line.start, shift_left_start),
        shift_point(line.finish, shift_left_finish)
      ),
      new_line(
        shift_point(line.start, shift_right_start),
        shift_point(line.finish, shift_right_finish)
      )
    )
  end

  # -------------------- Tiled Area Border -------------------

  @spec border(list(point())) :: list(line())
  def border([first_tile | _rest] = tiles) do
    tiles = tiles ++ [first_tile]

    {_tile, edges, _direction, clockwise_turns} =
      Enum.reduce(
        tiles,
        {nil, [], nil, 0},
        fn tile, {last_tile, edges, last_direction, clockwise_turns} ->
          cond do
            last_tile == nil ->
              {tile, edges, last_direction, clockwise_turns}

            last_direction == nil ->
              line = new_line(last_tile, tile)
              direction = line_direction(line)

              {
                tile,
                [bordering_edges(line) | edges],
                direction,
                clockwise_turns
              }

            true ->
              line = new_line(last_tile, tile)
              direction = line_direction(line)

              clockwise_turn_change =
                case change_direction(last_direction, direction) do
                  :clockwise -> 1
                  :counterclockwise -> -1
                end

              {
                tile,
                [bordering_edges(line) | edges],
                direction,
                clockwise_turns + clockwise_turn_change
              }
          end
        end
      )

    if clockwise_turns >= 0 do
      Enum.map(edges, fn edge -> edge.left_edge end)
    else
      Enum.map(edges, fn edge -> edge.right_edge end)
    end
  end

  def overlaps_border?(rect, border) do
    Enum.any?(
      border,
      fn border_part -> rect_overlaps?(rect, border_part) end
    )
  end

  # -------------------- Largest Rectangle -------------------

  @spec largest_rectangle2(list(point())) :: rectangle()
  def largest_rectangle2(tiles) do
    border = border(tiles)

    pair_combos(tiles)
    |> Enum.map(fn {tile1, tile2} -> new_rectangle(tile1, tile2) end)
    |> Enum.reject(fn rect -> overlaps_border?(rect, border) end)
    |> Enum.max_by(&rectangle_area/1)
  end

  # ------------------------- Answer -------------------------

  @spec part_2_answer(Path.t()) :: integer()
  def part_2_answer(path) do
    with {:ok, binary} = File.read(path) do
      parse_file(binary)
      |> largest_rectangle2()
      |> rectangle_area()
    end
  end
end
