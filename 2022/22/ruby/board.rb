# frozen_string_literal: true

require_relative 'tile'
require_relative 'connection'
require_relative 'position'

class Board
  attr_reader :whole, :tile_neighbors, :tiles, :index, :tile_dimension

  def initialize(input, type)
    @whole = input.chomp.split("\n").map(&:chars)

    @tile_dimension = @whole.map(&:size).reduce(&:gcd)

    @tiles = {}
    @index = {}
    @tile_neighbors = []

    cut_tiles
    pad_tile_neighbors
    find_connections(type)
  end

  def pad_tile_neighbors
    max_width = tile_neighbors.map(&:size).max
    tile_neighbors.map do |row|
      (max_width - row.size).times { row << :blank}
    end
  end

  def cut_tiles
    @tile_neighbors << []
    row, y, x = 0, 0, 0

    loop do
      return if whole[y].nil?

      if whole[y][x].nil?
        row, y, x = row + 1, y + @tile_dimension, 0
      elsif whole[y][x] != ' '
        @tile_neighbors[row] ||= []
        tile = cut_tile(y, x, @tile_dimension)
        @tile_neighbors[row] << [(@tiles.size + 1), tile]

        x += @tile_dimension
      else
        @tile_neighbors[row] ||= []
        @tile_neighbors[row] << :blank

        x += @tile_dimension
      end
    end
  end

  def cut_tile(y, x, dimension)
    grid = []

    (y...y + dimension).each do |y|
      grid << []
      (x...x + dimension).each do |x|
        grid[-1] << whole[y][x]
      end
    end

    tile = Tile.new([y, x], grid, @tiles.size + 1)

    @tiles[tile.position] = tile
    @index[tile.label] = tile
  end

  def find_connections(type)
    case type
    when :flat
      find_flat_connections
    when :cuboid
      find_cuboidal_connections
    else
      raise 'not supported'
    end
  end

  def find_cuboidal_connections
    (0...tile_neighbors.size).each do |y|
      (0...tile_neighbors[y].size).each do |x|
        %i[up down left right].each do |d|
          next if tile_neighbors[y][x].nil? || tile_neighbors[y][x] == :blank

          _, tile = tile_neighbors[y][x]
          found_tile, found_orientation = find_cuboidal_neighbor(d, [y, x])

          c = Connection.new(tile, found_tile, tile.position, found_tile.position, 0, found_orientation)

          tile.set_connection(d, c)
        end
      end
    end
  end

  def find_cuboidal_neighbor(direction, position)
    mapping =
      case tile_dimension
      when 4
        {
          [0, 2] => {
            up: [index[2], 180],
            right: [index[6], 180],
            left: [index[3], 90],
            down: [index[4], 0]
          },
          [1, 0] => {
            up: [index[1], 180],
            right: [index[3], 0],
            left: [index[6], 270],
            down: [index[5], 180]
          },
          [1, 1] => {
            up: [index[1], 270],
            right: [index[4], 0],
            left: [index[2], 0],
            down: [index[5], 90]
          },
          [1, 2] => {
            up: [index[1], 0],
            right: [index[6], 270],
            left: [index[3], 0],
            down: [index[5], 0]
          },
          [2, 2] => {
            up: [index[4], 0],
            right: [index[6], 0],
            left: [index[3], 270],
            down: [index[2], 180]
          },
          [2, 3] => {
            up: [index[4], 90],
            right: [index[1], 180],
            left: [index[5], 0],
            down: [index[2], 90]
          }
        }
      when 50
        {
          [0, 1] => {
            up: [index[6], 270],
            right: [index[2], 0],
            left: [index[4], 180],
            down: [index[3], 0]
          },
          [0, 2] => {
            up: [index[6], 0],
            right: [index[5], 180],
            left: [index[1], 0],
            down: [index[3], 270]
          },
          [1, 1] => {
            up: [index[1], 0],
            right: [index[2], 90],
            left: [index[4], 90],
            down: [index[5], 0]
          },
          [2, 0] => {
            up: [index[3], 270],
            right: [index[5], 0],
            left: [index[1], 180],
            down: [index[6], 0]
          },
          [2, 1] => {
            up: [index[3], 0],
            right: [index[2], 180],
            left: [index[4], 0],
            down: [index[6], 270]
          },
          [3, 0] => {
            up: [index[4], 0],
            right: [index[5], 90],
            left: [index[1], 90],
            down: [index[2], 0]
          }
        }
      else
        raise 'unknown dimension'
      end

    mapping[position][direction]
  end

  def find_flat_connections
    (0...tile_neighbors.size).each do |y|
      (0...tile_neighbors[y].size).each do |x|
        %i[up down left right].each do |d|
          next if tile_neighbors[y][x].nil? || tile_neighbors[y][x] == :blank

          _, tile = tile_neighbors[y][x]
          found_tile = flat_find_tile(d, [y, x])

          c = Connection.new(tile, found_tile, tile.position, found_tile.position, 0, 0)

          tile.set_connection(d, c)
        end
      end
    end
  end

  def flat_find_tile(direction, position)
    n = Position.translate(position, direction)
    loop do
      n_tile = (tile_neighbors[n[0]] || [])[n[1]]
      if n_tile == :blank
        n = Position.translate(n, direction)
      elsif n_tile.nil?
        n = flat_loop_around(n, direction)
      else
        return n_tile[1]
      end
    end
  end

  def flat_loop_around(position, direction)
    y, x = position

    case direction
    when :up
      [tile_neighbors.size - 1, x]
    when :down
      [0, x]
    when :left
      [y, tile_neighbors[0].size - 1]
    when :right
      [y, 0]
    end
  end

  def to_s
    <<~END_STRING
      Layout:
      #{tile_neighbors.map { |row| row.map { |n| n == :blank ? '.' : n[1].label }.join('') }.join("\n")}

      #{tiles.values.map(&:to_s).join("\n")}
    END_STRING
  end
end
