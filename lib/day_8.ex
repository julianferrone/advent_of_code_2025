defmodule Day8 do
  # _________________________ Part 1 _________________________

  # ------------------------- Parsing ------------------------
  def parse_line(line) do
    String.split(line, ",", parts: 3)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def parse_file(binary) do
    binary
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> Enum.reject(fn s -> s == "" end)
    |> Enum.map(&parse_line/1)
  end

  # ------------------- Euclidean Distance -------------------

  def squared_distance({x1, y1, z1}, {x2, y2, z2}) do
    Enum.map(
      [
        x1 - x2,
        y1 - y2,
        z1 - z2
      ],
      fn diff -> Integer.pow(diff, 2) end
    )
    |> Enum.sum()
  end

  def sorted_junction_boxes_by_distance(junction_boxes) do
    pair_combos(junction_boxes)
    |> Enum.map(fn
      {junction_box1, junction_box2} ->
        distance = squared_distance(junction_box1, junction_box2)
        {distance, junction_box1, junction_box2}
    end)
    |> Enum.sort_by(fn {distance, _junction_box1, _junction_box2} -> distance end)
  end

  # ---------------------- Combinations ----------------------

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

  # ----------------- Connect Junction Boxes -----------------

  def get_circuit_id(circuits, junction_box) do
    Map.get(circuits.circuit_map, junction_box)
  end

  def connect_to_circuit(circuits, junction_box, circuit_id) do
    Map.update(
      circuits,
      :circuit_map,
      %{},
      fn circuit_map ->
        Map.put(circuit_map, junction_box, circuit_id)
      end
    )
  end

  def connect_to_new_circuit(circuits, junction_box) do
    connect_to_circuit(circuits, junction_box, circuits.new_circuit_id)
  end

  def connect_circuits_together(circuits, circuit1, circuit2) do
    Map.update(
      circuits,
      :circuit_map,
      %{},
      fn circuit_map ->
        Enum.map(
          circuit_map,
          fn {junction_box, original_circuit_id} ->
            if original_circuit_id in [circuit1, circuit2] do
              {junction_box, circuit1}
            else
              {junction_box, original_circuit_id}
            end
          end
        )
        |> Enum.into(%{})
      end
    )
    |> increment_map_key(:unique_circuit_count, -1)
  end

  def increment_map_key(map, key, delta) do
    Map.update(map, key, 0, &(&1 + delta))
  end

  def connect_junction_boxes(junction_box_pairs) do
    connected =
      Enum.reduce(
        junction_box_pairs,
        %{circuit_map: %{}, new_circuit_id: 0},
        fn {junction_box1, junction_box2}, circuits ->
          junction_box1_circuit = get_circuit_id(circuits, junction_box1)
          junction_box2_circuit = get_circuit_id(circuits, junction_box2)

          case {junction_box1_circuit, junction_box2_circuit} do
            {nil, nil} ->
              circuits
              |> connect_to_new_circuit(junction_box1)
              |> connect_to_new_circuit(junction_box2)
              |> increment_map_key(:new_circuit_id, 1)

            {circuit1, nil} ->
              connect_to_circuit(circuits, junction_box2, circuit1)

            {nil, circuit2} ->
              connect_to_circuit(circuits, junction_box1, circuit2)

            # If the junction boxes are already connected to the same circuit, no
            # need to change anything
            {circuit, circuit} ->
              circuits

            {circuit1, circuit2} ->
              connect_circuits_together(circuits, circuit1, circuit2)
          end
        end
      )

    connected.circuit_map
  end

  def get_circuit_sizes(circuit_map) do
    Enum.reduce(
      circuit_map,
      %{},
      fn {_junction_box, circuit_id}, circuit_sizes ->
        Map.update(
          circuit_sizes,
          circuit_id,
          1,
          fn existing -> existing + 1 end
        )
      end
    )
  end

  # ------------------------- Answer -------------------------

  def part_1_answer(path) do
    with {:ok, binary} = File.read(path) do
      parse_file(binary)
      |> sorted_junction_boxes_by_distance()
      |> Enum.map(fn {_distance, junction_box1, junction_box2} ->
        {junction_box1, junction_box2}
      end)
      |> Enum.take(1000)
      |> connect_junction_boxes()
      |> get_circuit_sizes()
      |> Enum.map(fn {_circuit_id, size} -> size end)
      |> Enum.sort(:desc)
      |> Enum.take(3)
      |> Enum.product()
    end
  end

  # _________________________ Part 2 _________________________

  def connect_until_same_circuit(junction_box_pairs, junction_box_count) do
    connect_until_same_circuit(
      junction_box_pairs,
      junction_box_count,
      %{
        # Map of junction boxes coordinates to circuit IDs
        circuit_map: %{},
        new_circuit_id: 0,
        unique_circuit_count: 0,
        junction_box_count: 0
      }
    )
  end

  def connect_until_same_circuit([], _junction_box_count, _circuits) do
    # We should never reach this -- we eventually end up connecting ALL
    # the junction boxes, so we'll not run out of `junction_box_pairs` to test.
    nil
  end

  def connect_until_same_circuit(
        [{junction_box1, junction_box2} | junction_box_pairs],
        junction_box_count,
        circuits
      ) do
    junction_box1_circuit = get_circuit_id(circuits, junction_box1)
    junction_box2_circuit = get_circuit_id(circuits, junction_box2)

    circuits =
      case {junction_box1_circuit, junction_box2_circuit} do
        {nil, nil} ->
          circuits
          |> connect_to_new_circuit(junction_box1)
          |> connect_to_new_circuit(junction_box2)
          |> increment_map_key(:new_circuit_id, 1)
          |> increment_map_key(:unique_circuit_count, 1)
          |> increment_map_key(:junction_box_count, 2)

        {circuit1, nil} ->
          circuits
          |> connect_to_circuit(junction_box2, circuit1)
          |> increment_map_key(:junction_box_count, 1)

        {nil, circuit2} ->
          circuits
          |> connect_to_circuit(junction_box1, circuit2)
          |> increment_map_key(:junction_box_count, 1)

        {circuit, circuit} ->
          circuits

        {circuit1, circuit2} ->
          connect_circuits_together(circuits, circuit1, circuit2)
      end

    if Enum.all?([
         circuits.junction_box_count == junction_box_count,
         circuits.unique_circuit_count == 1
       ]) do
      {junction_box1, junction_box2}
    else
      connect_until_same_circuit(junction_box_pairs, junction_box_count, circuits)
    end
  end

  # ------------------------- Answer -------------------------

  def part_2_answer(path) do
    with {:ok, binary} = File.read(path) do
      junction_boxes = parse_file(binary)
      junction_box_count = length(junction_boxes)

      {{x1, _y1, _z1}, {x2, _y2, _z2}} =
        sorted_junction_boxes_by_distance(junction_boxes)
        |> Enum.map(fn {_distance, junction_box1, junction_box2} ->
          {junction_box1, junction_box2}
        end)
        |> connect_until_same_circuit(junction_box_count)

      x1 * x2
    end
  end
end
