class Tile
  attr_reader :grid, :position, :connections, :label

  def initialize(position, grid, label)
    @position = position
    @grid = grid
    @label = label
    @connections = {}
  end

  def set_connection(d, connection)
    @connections[d] = connection
  end

  def to_s
    <<~END_OF_STRING
      Tile #{label} @ {#{position[0]}, #{position[1]}}:
        Connections:
          - U: Tile #{connections[:up].to.label} @ {#{connections[:up].to.position[0]}, #{connections[:up].to.position[1]}}
          - D: Tile #{connections[:down].to.label} @ {#{connections[:down].to.position[0]}, #{connections[:down].to.position[1]}}
          - L: Tile #{connections[:left].to.label} @ {#{connections[:left].to.position[0]}, #{connections[:left].to.position[1]}}
          - R: Tile #{connections[:right].to.label} @ {#{connections[:right].to.position[0]}, #{connections[:right].to.position[1]}}
    END_OF_STRING
  end
end
