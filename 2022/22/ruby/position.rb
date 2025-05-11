# frozen_string_literal: true

module Position
  def self.translate(position, d)
    py, px = position
    case d
    when Array
      dy, dx = d
      [py + dy, px + dx]
    when Symbol
      case d
      when :up
        [py - 1, px]
      when :down
        [py + 1, px]
      when :left
        [py, px - 1]
      when :right
        [py, px + 1]
      else
        raise 'not supported direction'
      end
    end
  end
end
