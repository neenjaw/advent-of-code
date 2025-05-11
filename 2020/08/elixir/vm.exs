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

  @spec tick(map(), State.t(), map()) :: {:ok, State.t()} | {:error, String.t(), State.t()}
  def tick(_program, %State{position: pos, visited: visited} = state, _options)
      when is_map_key(visited, pos) do
    {:error, "infinite loop detected", state}
  end

  def tick(program, %State{position: pos} = state, _options) when pos == map_size(program) do
    {:ok, state}
  end

  def tick(program, %State{position: pos, visited: visited} = state, options) do
    with {:instruction, {instruction, value}} <- {:instruction, program[pos]},
         {:mutation, instruction} <- {:mutation, mutate_instruction(instruction, state, options)},
         {:next, next_state} <- {:next, handle_instruction(state, instruction, value)},
         next_state <- %{next_state | visited: Map.put(visited, pos, true)} do
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

# Get the program from file
program =
  System.argv()
  |> hd()
  |> File.stream!()
  |> Stream.with_index()
  |> Stream.map(&VM.process_instruction/1)
  |> Enum.into(%{})

# Find a solution where flipping one "jmp"-"nop" instruction causes program to correctly halt
{:ok, %{acc: acc}} =
  program
  |> Stream.filter(fn
    {_, {instruction, _}} when instruction in ~w[jmp nop] -> true
    _ -> false
  end)
  |> Stream.map(&elem(&1, 0))
  |> Enum.sort()
  |> Stream.map(fn possible_error_index -> VM.run(program, %{flip_at: possible_error_index}) end)
  |> Enum.find(fn
    {:ok, _} -> true
    _ -> false
  end)

"Part 2 Solution: #{acc}" |> IO.puts()
