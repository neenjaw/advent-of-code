# frozen_string_literal: true

State = Struct.new(:tile, :rel_position, :abs_position, :translation)
Point = Struct.new(:y, :x, :heading)
Translation = Struct.new(:from, :to)

class Visitor
  attr_reader :board

  def initialize(board)
    @board = board
  end

  def new_state
    tile = board.index[1]
    t = Translation.new(0, 0)
    r = Point.new(0, 0, 0)
    a = convert_to_absolute(r, t, tile)

    State.new(tile, r, a, t)
  end

  def new_state_from_state(state)
    copy_rel_position = Point.new(state.rel_position.y, state.rel_position.x, state.rel_position.heading)
    copy_abs_position = Point.new(state.abs_position.y, state.abs_position.x, state.abs_position.heading)
    copy_translation = Translation.new(state.translation.from, state.translation.to)

    State.new(state.tile, copy_rel_position, copy_abs_position, copy_translation)
  end

  def convert_to_absolute(p, t, tile)
    abs_rotated =
      case [t.from, t.to]
      when [0, 0]
        Point.new(p.y, p.x, p.heading)
      else
        raise "Translation from #{t.from}, to #{t.to} for point {#{p.y}, #{p.x}} heading #{p.heading} not implemented"
      end

    dy, dx = tile.position
    abs_rotated.y += dy
    abs_rotated.x += dx

    abs_rotated
  end

  def score_state(state)
    pp [:score_state, state.abs_position.y, state.abs_position.x, state.abs_position.heading] if $dbg
    (1000 * (state.abs_position.y + 1)) + (4 * (state.abs_position.x + 1)) + state.abs_position.heading
  end

  def run(instructions)
    count = 0
    end_state =
      instructions.inject(new_state) do |state, instruction|
        count += 1
        step_result =
          case instruction
          when Integer
            # pp [:moving, instruction]
            handle_move(state, instruction)
          when String
            # pp [:turning, instruction]
            handle_turn(state, instruction)
          end

        # pp [:step_result, step_result.tile.label, step_result.rel_position, step_result.abs_position]
        # raise "!" if count ==
        step_result
      end

    # pp end_state
    score_state(end_state)
  end

  def handle_turn(state, turn)
    next_state = new_state_from_state(state)

    case turn
    when 'L'
      next_state.rel_position.heading -= 1
      next_state.rel_position.heading += 4 if next_state.rel_position.heading.negative?
      next_state.abs_position.heading -= 1
      next_state.abs_position.heading += 4 if next_state.abs_position.heading.negative?
    when 'R'
      next_state.rel_position.heading += 1
      next_state.rel_position.heading %= 4
      next_state.abs_position.heading += 1
      next_state.abs_position.heading %= 4
    else
      raise "unhandled turn #{turn}"
    end

    next_state
  end

  def handle_move(state, count)
    # pp [:move, state.rel_position, count]
    return state if count.zero?

    next_state = new_state_from_state(state)

    case next_state.rel_position.heading
    when 0 # right
      next_state.rel_position.x += 1
    when 1 # down
      next_state.rel_position.y += 1
    when 2 # left
      next_state.rel_position.x -= 1
    when 3 # up
      next_state.rel_position.y -= 1
    else
      raise "unhandled heading for move: #{next_state.rel_position.heading}"
    end

    # Check bounds +/- transition to a new tile
    if next_state.rel_position.x >= board.tile_dimension
      handle_tile_transition(next_state, :right)
    elsif next_state.rel_position.x.negative?
      handle_tile_transition(next_state, :left)
    elsif next_state.rel_position.y.negative?
      handle_tile_transition(next_state, :up)
    elsif next_state.rel_position.y >= board.tile_dimension
      handle_tile_transition(next_state, :down)
    end

    next_state.abs_position = convert_to_absolute(next_state.rel_position, next_state.translation, next_state.tile)

    # pp [:attempt, next_state.abs_position]

    # Check the tile content
    tile_content = next_state.tile.grid[next_state.rel_position.y][next_state.rel_position.x]
    case tile_content
    when '#'
      pp [:blocked, next_state.tile.label, next_state.tile.grid, tile_content] if $dbg
      state
    when '.'
      handle_move(next_state, count - 1)
    else
      pp [:tile_content, tile_content, next_state.tile.label, next_state.tile.label, next_state.tile.grid, next_state.rel_position, next_state.rel_position] if $dbg
      raise "unhandled '#{tile_content}' tile content"
    end
  end
end

class CuboidVisitor < Visitor
  def handle_tile_transition(state, transition_direction)
    conn = state.tile.connections[transition_direction]

    case transition_direction
    when :up
      state.rel_position.y = board.tile_dimension - 1
    when :right
      state.rel_position.x = 0
    when :down
      state.rel_position.y = 0
    when :left
      state.rel_position.x = board.tile_dimension - 1
    else
      raise "unhandled transition_direction #{transition_direction}"
    end

    case [transition_direction, conn.from_orientation, conn.to_orientation]
    when [:right, 0, 0], [:up, 0, 0], [:down, 0, 0], [:left, 0, 0]
      nil
    when [:right, 0, 270]
      state.rel_position.x = board.tile_dimension - 1 - state.rel_position.y
      state.rel_position.y = 0
      state.rel_position.heading = 1
    when [:right, 0, 180]
      state.rel_position.x = board.tile_dimension - 1
      state.rel_position.y = board.tile_dimension - 1 - state.rel_position.y
      state.rel_position.heading = 2
    when [:right, 0, 90]
      state.rel_position.x = state.rel_position.y
      state.rel_position.y = board.tile_dimension - 1
      state.rel_position.heading = 3
    when [:down, 0, 180]
      state.rel_position.x = board.tile_dimension - 1 - state.rel_position.x
      state.rel_position.y = board.tile_dimension - 1
      state.rel_position.heading = 3
    when [:down, 0, 270]
      state.rel_position.y = state.rel_position.x
      state.rel_position.x = board.tile_dimension - 1
      state.rel_position.heading = 2
    when [:left, 0, 90]
      state.rel_position.x = state.rel_position.y
      state.rel_position.y = 0
      state.rel_position.heading = 1
    when [:left, 0, 180]
      state.rel_position.x = 0
      state.rel_position.y = board.tile_dimension - 1 - state.rel_position.y
      state.rel_position.heading = 0
    when [:up, 0, 270]
      state.rel_position.y = state.rel_position.x
      state.rel_position.x = 0
      state.rel_position.heading = 0
    else
      pp [transition_direction, conn.from.label, conn.to.label, state.tile.connections[transition_direction].to.position]
      raise "not implemented rotation of #{conn.from_orientation} to #{conn.to_orientation}"
    end

    # pp [:transition, conn.from.label, conn.to.label, state.rel_position, transition_direction]

    state.tile = state.tile.connections[transition_direction].to
    state
  end
end

class FlatVisitor < Visitor
  def handle_tile_transition(state, transition_direction)
    state.tile = state.tile.connections[transition_direction].to

    case transition_direction
    when :up
      state.rel_position.y = board.tile_dimension - 1
    when :right
      state.rel_position.x = 0
    when :down
      state.rel_position.y = 0
    when :left
      state.rel_position.x = board.tile_dimension - 1
    else
      raise "unhandled transition_direction #{transition_direction}"
    end
  end
end
