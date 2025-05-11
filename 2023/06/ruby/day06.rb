class RaceCalculator
  def initialize(input)
    @input = input
  end

  def calculate_races
    races = @input.transpose.map do |time, distance_record|
      wins = 0
      pause = 0

      while pause < time
        pause += 1
        distance = pause * (time - pause)
        wins += 1 if distance > distance_record
      end

      wins
    end

    races.inject(&:*)
  end

  def calculate_win_start
    time, distance_record = @input.map(&:join).map(&:to_i)

    min = 0
    max = time
    middle = (min + max) / 2
    win_start = -1

    while min < max
      pause = middle
      prev_pause = pause - 1

      distance = pause * (time - pause)
      prev_distance = prev_pause * (time - prev_pause)

      if distance > distance_record && prev_distance <= distance_record
        win_start = pause
        break
      elsif prev_distance > distance_record
        max = middle - 1
      elsif distance <= distance_record
        min = middle + 1
      end
      middle = (min + max) / 2
    end

    win_start
  end

  def calculate_win_end
    time, distance_record = @input.map(&:join).map(&:to_i)

    min = 0
    max = time
    middle = (min + max) / 2
    win_end = -1

    while min < max
      pause = middle
      next_pause = pause + 1

      distance = pause * (time - pause)
      next_distance = next_pause * (time - next_pause)

      if distance > distance_record && next_distance <= distance_record
        win_end = pause
        break
      elsif next_distance > distance_record
        min = middle + 1
      elsif distance <= distance_record
        max = middle - 1
      end
      middle = (min + max) / 2
    end

    win_end = max if win_end == -1

    win_end
  end

  def calculate_win_length
    win_end = calculate_win_end
    win_start = calculate_win_start

    win_end - win_start + 1
  end
end

input = ARGF.read.chomp.split("\n").map { |line| line.chomp.split.drop(1).map(&:to_i) }

race_calculator = RaceCalculator.new(input)

pp race_calculator.calculate_races
pp race_calculator.calculate_win_start
pp race_calculator.calculate_win_end
pp race_calculator.calculate_win_length
