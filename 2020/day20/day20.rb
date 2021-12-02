# frozen_string_literal: true

require 'deep_clone'

IMAGE_DOT = '.'
IMAGE_POUND = '#'

ORIENTATION_VARIABLES = [[0, 90, 180, 270], [false, true], [false, true]].freeze
ORIENTATION_COMBINATIONS = ORIENTATION_VARIABLES.first.product(*ORIENTATION_VARIABLES[1..])

# An Image Tile
class ImageTile
  attr_reader :data, :number, :edges, :rotation, :hflip, :vflip

  def initialize(number:, tile_data:, rotation: 0, hflip: false, vflip: false)
    @number = number
    @data = tile_data
    @edges = find_edges
    @rotation = rotation
    @hflip = hflip
    @vflip = vflip
  end

  def find_edges
    transposed = transpose
    { top: data[0], bottom: data[-1].reverse, left: transposed[0], right: transposed[-1] }
  end

  def flip_horizontal
    ImageTile.new(
      number: number,
      tile_data: data.map(&:reverse),
      hflip: !hflip,
      vflip: vflip,
      rotation: rotation
    )
  end

  def flip_vertical
    ImageTile.new(
      number: number,
      tile_data: data.reverse,
      hflip: hflip,
      vflip: !vflip,
      rotation: rotation
    )
  end

  def rotate_right
    ImageTile.new(
      number: number,
      tile_data: data.transpose.map(&:reverse),
      hflip: hflip,
      vflip: vflip,
      rotation: (rotation - 90) % 360
    )
  end

  def rotate_left
    ImageTile.new(
      number: number,
      tile_data: data.map(&:reverse).transpose,
      hflip: hflip,
      vflip: vflip,
      rotation: (rotation + 90) % 360
    )
  end

  def to_s(title: false)
    s = title ? String.new("Tile #{number}:\n") : String.new
    s << data.map { |row| row.join('') }.join("\n")
  end

  private

  def transpose
    data.transpose
  end
end

# contains information about each match
class Match
  attr_reader :number, :side, :rotation, :hflip, :vflip

  def initialize(number:, side:, rotation:, hflip:, vflip:)
    @number = number
    @side = side
    @rotation = rotation
    @hflip = hflip
    @vflip = vflip
  end
end

def side_complement(side)
  case side
  when :top
    :bottom
  when :left
    :right
  when :right
    :left
  when :bottom
    :top
  else
    raise ArgumentError, 'some other complement'
  end
end

class AdventImage
  SIDE_COMPLEMENTS = [%i[top bottom], %i[bottom top], %i[left right], %i[right left]].freeze

  attr_reader :tiles, :tile_store, :potential_matches

  def initialize(tiles)
    @tiles = tiles
    @tile_store = create_tile_store
    @potential_matches = compute_potentials

    # Print the tile with debug information
    # puts(tile_store.keys.filter { |(n, _, _, _)| n == 2311 }.map do |(n, r, v, h)|
    #   String.new << "tile: #{n}, rot: #{r}, vflip: #{v}, hflip: #{h}\n" << fetch_from_store(n, r, v, h).to_s
    # end.join("\n\n"))

    # Print keys of tile store
    # pp(tile_store.keys)

    # Print potentials
    # pp potential_matches

    # Take a guess at the four corners, works for part 1
    # pp find_tile_search_order.take(4).reduce(&:*)
  end

  def find_order
    search_order = find_tile_search_order
    solution_found = false
    until solution_found || search_order.empty?
      origin = search_order.shift
      solution = Traverser.new(potential_matches, tile_store, origin, tiles.count).find
      solution_found = true if solution
    end
    raise 'No solution'
  end

  private

  def create_tile_store
    tiles.each_with_object({}) do |tile, store|
      store[[tile.number, tile.rotation, tile.vflip, tile.hflip]] = tile
    end
  end

  def fetch_from_store(tile, rotation, vflip, hflip)
    number = tile.is_a?(ImageTile) ? tile.number : tile

    tile_store[[number, rotation, vflip, hflip]] ||= compute_tile_variation(tile, rotation, vflip, hflip)
  end

  def compute_tile_variation(tile, rotation, vflip, hflip)
    tile
      .then do |t|
        case rotation
        when 0
          t
        when 90
          t.rotate_left
        when 180
          t.rotate_left.rotate_left
        when 270
          t.rotate_right
        else
          raise ArgumentError, 'unknown rotation'
        end
      end
      .then do |t|
        vflip ? t.flip_vertical : t
      end
      .then do |t|
        hflip ? t.flip_horizontal : t
      end
  end

  def compute_potentials
    tiles
      .each_with_object({}) do |tile, memo|
        tile_number = tile.number
        memo[tile_number] ||= new_potential_memo

        tile_edges = tile.edges

        (tiles - [tile]).each do |other_tile|
          ORIENTATION_COMBINATIONS.each do |(rotation, vertical, horizontal)|
            manipulated_tile_edges = fetch_from_store(other_tile, rotation, vertical, horizontal).edges

            SIDE_COMPLEMENTS.each do |(tile_side, other_side)|
              next if tile_edges[tile_side] != manipulated_tile_edges[other_side]

              match =
                Match.new(
                  number: other_tile.number,
                  side: other_side,
                  rotation: rotation,
                  vflip: vertical,
                  hflip: horizontal
                )

              memo[tile_number][tile_side] << match
            end
          end
        end
      end
  end

  def new_potential_memo
    { top: [], bottom: [], left: [], right: [] }
  end

  def find_tile_search_order
    potential_matches
      .entries
      .sort_by do |img_number, p_data|
        # p img_number
        # pp p_data

        sides_matching = p_data.values.count { |m| !m.empty? }
        potential_matches = p_data.values.sum(&:count)

        [sides_matching, potential_matches]
      end
      .map(&:first)
  end
end

class Traverser
  attr_reader :memo, :goal_length, :store, :path, :grid

  def initialize(memo, store, origin, goal_length)
    @store = store
    @memo = memo
    @path = []
    @grid = {}
    @goal_length = goal_length

    add_entry(number: origin, x: 0, y: 0, rotation: 0, hflip: false, vflip: false)
  end

  def add_entry(number:, x:, y:, rotation:, hflip:, vflip:)
    entry = {
      number: number,
      x: x,
      y: y,
      rotation: rotation,
      vflip: vflip,
      hflip: hflip
    }

    grid[[x, y]] = entry
    path.push(entry)
  end

  def remove_last_entry
    entry = path.pop
    grid.delete([entry[:x], entry[:y]])
  end

  def heading
    path.last[:rotation]
  end

  def hflip
    path.last[:hflip]
  end

  def vflip
    path.last[:vflip]
  end

  def current_image
    path.last[:number]
  end

  def current_coordinates
    current = path.last
    [current[:x], current[:y]]
  end

  def success?
    path.count == goal_length
  end

  def grid_space_occupied?(x, y)
    not grid[[x, y]].nil?
  end

  def find
    return path if path.length == goal_length

    options = memo[current_image].entries.flat_map { |side, matches| matches.map { |m| [side, m] } }

    until options.empty?
      # [[:top, :right], [:top, :left], [:bottom, :right], [:bottom, :left]]
      option = options.shift

      puts '>>> option'
      pp option
      puts '>>> path'
      pp path
      puts '>>> grid'
      pp grid

      next_x, next_y = find_next_coords(option, current_coordinates, heading, vflip, hflip)

      # Already an image here, fast fail
      next if grid_space_occupied?(next_x, next_y)

      next_oriented_tile = store[find_next_tile_orientation(option, heading, vflip, hflip)]

      next unless check_adjacent_edges(next_oriented_tile, next_x, next_y)

      add_entry(
        number: option[1].number,
        x: next_x,
        y: next_y,
        rotation: next_oriented_tile.rotation,
        hflip: next_oriented_tile.hflip,
        vflip: next_oriented_tile.vflip
      )

      result = find # recursive step

      if result && result.length == goal_length
        pp result
        return result
      else
        remove_last_entry
      end
    end
  end

  def check_adjacent_edges(tile, x, y)
    [[:right, 1, 0], [:bottom, 0, -1], [:left, -1, 0], [:top, 0, 1]]
      .map do |(dir, dx, dy)|
        entry = grid[[x + dx, y + dy]]
        [dir, entry] if entry
      end
      .compact
      .all? do |(dir, entry)|
        tile_edges =  tile.edges
        adjacent_tile_edges = store[[entry[:number], entry[:rotation], entry[:vflip], entry[:hflip]]].edges

        # pp tile_edges
        # pp adjacent_tile_edges

        case dir
        when :bottom
          tile_edges[:bottom] == adjacent_tile_edges[:top]
        when :top
          tile_edges[:top] == adjacent_tile_edges[:bottom]
        when :left
          tile_edges[:left] == adjacent_tile_edges[:right]
        when :right
          tile_edges[:right] == adjacent_tile_edges[:left]
        else
          raise 'unknown edge test side'
        end
      end
  end

  def find_next_coords(option, current_coordinates, heading, vflip, hflip)
    current_side, match = option
    x, y = current_coordinates

    dx = 0
    dy = 0

    case current_side
    when :top
      dy = vflip ? -1 : 1
    when :bottom
      dy = vflip ? 1 : -1
    when :left
      dx = hflip ? -1 : 1
    when :right
      dx = hflip ? 1 : -1
    else
      raise 'unknown side'
    end

    case heading
    when 0
      nil
    when 90
      dy, dx = [dx, dy]
    when 180
      dx = -dx
    when 270
      dy, dx = [-dx, dy]
    else
      raise 'unknown rotation'
    end

    [x + dx, y + dy]
  end

  def find_next_tile_orientation(option, heading, vflip, hflip)
    _, match = option
    next_heading = heading + match.rotation % 360
    [match.number, next_heading, match.vflip, match.hflip]
  end
end

# class Translator
#   def initialize
#     @rotation = 0
#     @top = :top
#     @bottom = :bottom
#     @left = :left
#     @right = :right
#   end

#   def vflip
#     @top, @bottom = [@bottom, @top]
#   end

#   def hflip
#     @left, @right = [@right, @left]
#   end

#   def rotate

#   private

#   def rotate_once

#   end
# end



image_tiles = File.read(ARGV[0]).chomp.split("\n\n").map do |entry|
  title, *tile_data = entry.split("\n")
  title =~ /Tile (\d+):/
  number = Regexp.last_match(1).to_i
  ImageTile.new(number: number, tile_data: tile_data.map { |row| row.split('') })
end

p AdventImage.new(image_tiles).find_order
