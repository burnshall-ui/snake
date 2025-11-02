defmodule Snake do
  @moduledoc """
  A classic Snake game running in the terminal, translated from GW-BASIC.
  """

  # Game constants based on the GW-BASIC version
  # We use a character-based grid instead of pixels.
  @screen_width 64
  @screen_height 24
  @game_fps 8
  @initial_snake_length 5

  # Game state structure
  defstruct snake: [],
            direction: :right,
            food: {0, 0},
            score: 0,
            game_over: false

  # ================================================
  # 1. MAIN ENTRY POINT
  # ================================================

  def main do
    # Prepare terminal for raw input
    :io.setopts(:standard_io, [:raw])

    try do
      initial_state = initialize_game()
      game_loop(initial_state)
    after
      # Restore terminal state (show cursor)
      IO.write(:stdio, "\e[?25h")
    end
  end

  # ================================================
  # 2. GAME INITIALIZATION
  # ================================================

  defp initialize_game do
    # Initial snake position (head first)
    start_x = div(@screen_width, 2)
    start_y = div(@screen_height, 2)

    initial_snake =
      Enum.to_list(0..(@initial_snake_length - 1))
      |> Enum.map(fn i -> {start_x - i, start_y} end)

    %__MODULE__{
      snake: initial_snake,
      direction: :right,
      score: 0,
      game_over: false
    }
    |> place_food()
  end

  # ================================================
  # 3. GAME LOOP
  # ================================================

  defp game_loop(state) do
    render(state)
    Process.sleep(div(1000, @game_fps))

    # Non-blocking input read
    input = read_input()

    new_state =
      state
      |> handle_input(input)
      |> update_snake()
      |> check_collisions()

    if new_state.game_over do
      handle_game_over(new_state)
    else
      game_loop(new_state)
    end
  end

  # ================================================
  # 4. GAME LOGIC FUNCTIONS
  # ================================================

  defp read_input, do: IO.read(:stdio, 1024)

  defp handle_input(state, <<27, 91, 65>>) when state.direction != :down,  do: %{state | direction: :up}
  defp handle_input(state, <<27, 91, 66>>) when state.direction != :up,    do: %{state | direction: :down}
  defp handle_input(state, <<27, 91, 67>>) when state.direction != :left,  do: %{state | direction: :right}
  defp handle_input(state, <<27, 91, 68>>) when state.direction != :right, do: %{state | direction: :left}
  defp handle_input(state, <<27>>), do: %{state | game_over: true} # ESC
  defp handle_input(state, _), do: state # Ignore other keys

  defp update_snake(state) do
    %{snake: [head | _] = snake, direction: direction, food: food_pos} = state
    {hx, hy} = head

    new_head = case direction do
      :up    -> {hx, hy - 1}
      :down  -> {hx, hy + 1}
      :left  -> {hx - 1, hy}
      :right -> {hx + 1, hy}
    end

    eats_food = new_head == food_pos

    new_snake = if eats_food do
      # Grow snake by prepending new head
      [new_head | snake]
    else
      # Move snake by prepending new head and removing tail
      [new_head | Enum.slice(snake, 0, length(snake) - 1)]
    end

    new_state = %{state | snake: new_snake}

    if eats_food do
      new_state
      |> Map.update!(:score, &(&1 + 10))
      |> place_food()
    else
      new_state
    end
  end

  defp check_collisions(state) do
    %{snake: [head | body]} = state
    {hx, hy} = head

    wall_collision =
      hx <= 0 || hx >= @screen_width - 1 ||
      hy <= 0 || hy >= @screen_height - 1

    self_collision = head in body

    if wall_collision || self_collision do
      %{state | game_over: true}
    else
      state
    end
  end

  defp place_food(state) do
    # Logic to place food randomly
    # ensuring it's not on the snake.
    %{snake: snake} = state

    food_pos = Stream.repeatedly(fn ->
      x = :rand.uniform(@screen_width - 2) + 1
      y = :rand.uniform(@screen_height - 2) + 1
      {x, y}
    end)
    |> Enum.find(fn pos -> not (pos in snake) end)

    %{state | food: food_pos}
  end

  # ================================================
  # 5. RENDERING & GAME OVER
  # ================================================

  defp render(state) do
    # Clear screen and hide cursor
    IO.write(:stdio, "\e[2J\e[H\e[?25l")

    # Draw border
    draw_border()

    # Draw snake
    Enum.each(state.snake, fn {x, y} ->
      IO.write(:stdio, "\e[#{y};#{x}H█")
    end)

    # Draw food
    {fx, fy} = state.food
    IO.write(:stdio, "\e[#{fy};#{fx}H*")

    # Draw score
    IO.write(:stdio, "\e[#{@screen_height};2HSCORE: #{state.score}  LENGTH: #{length(state.snake)}")
  end

  defp draw_border do
    # Top/Bottom border
    border_line = String.duplicate("=", @screen_width)
    IO.write(:stdio, "\e[1;1H#{border_line}")
    IO.write(:stdio, "\e[#{@screen_height - 1};1H#{border_line}")

    # Left/Right border
    for y <- 2..(@screen_height - 2) do
      IO.write(:stdio, "\e[#{y};1H|")
      IO.write(:stdio, "\e[#{y};#{@screen_width}H|")
    end
  end

  defp handle_game_over(state) do
    # Show cursor again
    IO.write(:stdio, "\e[?25h")

    mid_y = div(@screen_height, 2)
    mid_x = div(@screen_width - 15, 2)

    IO.write(:stdio, "\e[#{mid_y};#{mid_x}H*** GAME OVER ***")
    IO.write(:stdio, "\e[#{mid_y + 1};#{mid_x}HFINAL SCORE: #{state.score}")
    IO.write(:stdio, "\e[#{mid_y + 3};#{mid_x - 5}HPress SPACE to restart or ESC to quit.")

    case IO.read(:stdio, 1) do
      " "      -> main() # Restart
      <<27>>   -> :ok # Quit
      _        -> handle_game_over(state) # Wait for valid input
    end
  end
end

# Start the game
Snake.main()
