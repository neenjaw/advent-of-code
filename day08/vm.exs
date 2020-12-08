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

  @spec tick(map(), State.t(), map()) :: {:ok, State.t()} | :error
  def tick(program, %State{position: pos} = state, options) when pos == map_size(program) do
    {:ok, state}
  end

  def tick(program, %State{position: pos, acc: acc, visited: visited} = state, options) do
    with {:instruction, {instruction, value}} <- {:instruction, program[pos]},
         {:mutation, instruction} <- {:mutation, mutate_instruction(instruction, state, options)},
         {:update_visited, visited} <- {:update_visited, Map.put(visited, pos, true)},
         {:next, next_state} <- {:next, handle_instruction(state, instruction, value)},
         {:detect_inf_loop, false} <-
           {:detect_inf_loop, not (visited[next_state.position] == nil)} do
      tick(program, next_state, options)
    end
  end

  def mutate_instruction("nop", %State{position: pos}, %{flip_at: pos}), do: "jmp"
  def mutate_instruction("jmp", %State{position: pos}, %{flip_at: pos}), do: "nop"
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
end

program =
  System.argv()
  |> hd()
  |> File.stream!()
  |> Stream.with_index()
  |> Stream.map(&VM.process_instruction/1)
  |> Enum.into(%{})
  |> IO.inspect(label: "63")

possible_error_indices =
  program
  |> Stream.filter(fn
    {_, {instruction, _}} when instruction in ~w[jmp nop] -> true
    _ -> false
  end)
  |> Stream.map(&elem(&1, 0))
  |> Enum.sort()

VM.run(program, %{flip_at: 7}) |> IO.inspect(label: "result")
