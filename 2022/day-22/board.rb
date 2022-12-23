# frozen_string_literal: true

require_relative 'tile'
require_relative 'connection'
require_relative 'position'

class Board
  attr_reader :whole, :tile_neighbors, :tiles

  def initialize(input, type)
    @whole = input.chomp.split("\n").map(&:chars)

    @tile_dimension = @whole.map(&:size).reduce(&:gcd)

    @tiles = {}
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

    @tiles[[y, x]] = Tile.new([y, x], grid, @tiles.size + 1)
  end

  def find_connections(type)
    case type
    when :flat
      find_flat_connections
    when :cuboid
      raise 'not implemented'
    else
      raise 'not supported'
    end
  end

  def find_flat_connections
    (0...tile_neighbors.size).each do |y|
      (0...tile_neighbors[y].size).each do |x|
        %i[up down left right].each do |d|
          next if tile_neighbors[y][x].nil? || tile_neighbors[y][x] == :blank

          _, tile = tile_neighbors[y][x]
          found_tile = flat_find_tile(d, [y, x])

          c = Connection.new(tile, found_tile, tile.position, found_tile.position, :up, :up)

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
      #{tile_neighbors.map {|row| row.map { |n| n == :blank ? '.' : n[1].label }.join("") }.join("\n")}

      #{tiles.values.map(&:to_s).join("\n")}
    END_STRING
  end
end
