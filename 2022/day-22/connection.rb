class Connection
  attr_accessor :from, :to, :from_position, :to_position, :from_orientation, :to_orientation

  def initialize(from, to, from_pos, to_pos, from_orientation, to_orientation)
    @from = from
    @to = to
    @from_pos = from_pos
    @to_pos = to_pos
    @from_orientation = from_orientation
    @to_orientation = to_orientation
  end
end
