defmodule VM do
  defmodule State do
    defstruct position: 0, acc: 0, visited: %{}

    @type t() :: %__MODULE__{
            position: non_neg_integer(),
            acc: integer(),
            visited: map()
          }
  end

  def process_instruction({line, idx}) do
    [instruction, value] =
      line
      |> String.trim()
      |> String.split()

    {idx, {instruction, String.to_integer(value)}}
  end

  def run(program, options \\ %{}) do
    tick(program, %State{}, options)
  end

  def spawn_run(program, %{receiver: r, to_fork_at: f} = options) when is_pid(r) and is_list(f) do
    spawn(fn -> tick(program, %State{}, Map.put_new(options, :fork_at, nil)) end)
  end

  @spec tick(map(), State.t(), map()) :: {:ok, State.t()} | {:error, String.t(), State.t()}
  def tick(program, %State{position: pos} = state, options) when pos == map_size(program) do
    case options do
      %{receiver: r} -> send(r, {:ok, state, options})
    end

    {:ok, state}
  end

  def tick(program, %State{position: pos, visited: visited} = state, options) do
    with {:options, options} <- {:options, handle_possible_fork(program, state, options)},
         {:instruction, {instruction, value}} <- {:instruction, program[pos]},
         {:mutation, instruction} <- {:mutation, mutate_instruction(instruction, state, options)},
         {:update_visited, visited} <- {:update_visited, Map.put(visited, pos, true)},
         {:next, next_state} <- {:next, handle_instruction(state, instruction, value)},
         {:next, next_state} <- {:next, %{next_state | visited: visited}},
         {:detect_inf_loop, false, _} <-
           {:detect_inf_loop, not (visited[next_state.position] == nil), next_state} do
      tick(program, next_state, options)
    else
      {:detect_inf_loop, true, error_state} ->
        case options do
          %{receiver: r} ->
            send(r, {:error, error_state, options})
        end

        {:error, "infinite loop detected", error_state}
    end
  end

  def mutate_instruction("nop", %State{position: pos}, %{fork_at: pos}), do: "jmp"
  def mutate_instruction("jmp", %State{position: pos}, %{fork_at: pos}), do: "nop"
  def mutate_instruction(instruction, _state, _options), do: instruction

  def handle_instruction(%State{} = state, instruction, value) do
    case instruction do
      "jmp" ->
        %{state | position: state.position + value}

      "nop" ->
        %{state | position: state.position + 1}

      "acc" ->
        %{state | position: state.position + 1, acc: state.acc + value}
    end
  end

  def handle_possible_fork(program, state, options) do
    case options do
      %{fork_at: nil, to_fork_at: [possibility | rest]} ->
        spawn(fn -> tick(program, state, %{options | fork_at: possibility, to_fork_at: []}) end)
        %{options | to_fork_at: rest}

      _ ->
        options
    end
  end
end

defmodule Receiver do
  def listen(limit, count \\ 0) do
    count = count + 1

    receive do
      {:ok, %{acc: acc}, %{fork_at: nil}} ->
        {:ok, "Success! Result: #{acc}"}

      {:ok, %{acc: acc}, %{fork_at: pos}} ->
        {:ok, "Success! Flipped instruction at #{pos}, result: #{acc}"}

      {:error, _, %{fork_at: nil}} ->
        {:fail, "Fail! Tried without flipping"}

      {:error, _, %{fork_at: pos}} ->
        {:fail, "Fail! Tried flipping at #{pos}"}

      _ ->
        {:err, "Error! Unexpected message received"}
    after
      5000 ->
        {:err, "Error! No message in 5 seconds"}
    end
    |> case do
      {:ok, msg} ->
        IO.puts(msg)
        IO.puts("Success after #{count} forks")

      {:fail, msg} ->
        IO.puts(msg)
        listen(limit - 1, count)

      {:err, msg} ->
        IO.puts(:stderr, msg)
    end
  end
end

# Get the program from file
program =
  System.argv()
  |> hd()
  |> File.stream!()
  |> Stream.with_index()
  |> Stream.map(&VM.process_instruction/1)
  |> Enum.into(%{})

possible_instruction_errors =
  program
  |> Stream.filter(fn
    {_, {instruction, _}} when instruction in ~w[jmp nop] -> true
    _ -> false
  end)
  |> Stream.map(&elem(&1, 0))
  |> Enum.sort()

possible_count = length(possible_instruction_errors) + 1

VM.spawn_run(program, %{receiver: self(), to_fork_at: possible_instruction_errors})

Receiver.listen(possible_count)
