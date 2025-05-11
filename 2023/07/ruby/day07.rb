class Hand
  ORDER = [
    :five_of_a_kind,
    :four_of_a_kind,
    :full_house,
    :three_of_a_kind,
    :two_pairs,
    :one_pair,
    :high_card
  ]

  HAND_TYPE_VALUE = {
    five_of_a_kind: 7,
    four_of_a_kind: 6,
    full_house: 5,
    three_of_a_kind: 4,
    two_pairs: 3,
    one_pair: 2,
    high_card: 1
  }

  CARD_VALUE = {
    'A' => 14,
    'K' => 13,
    'Q' => 12,
    'J' => 11,
    'T' => 10,
    '9' => 9,
    '8' => 8,
    '7' => 7,
    '6' => 6,
    '5' => 5,
    '4' => 4,
    '3' => 3,
    '2' => 2,
    'JL' => 1
  }

  attr_reader :hand, :bid_value, :hand_type, :hand_type_value, :is_joker_wild

  def initialize(hand, bid_value)
    @hand = hand
    @bid_value = bid_value
    @hand_type = parse_hand_type
    @hand_type_value = HAND_TYPE_VALUE[hand_type]
    @is_joker_wild = false
  end

  def <=>(other_hand)
    if hand_type == other_hand.hand_type
      winner =
        hand.chars.zip(other_hand.hand.chars).each do |card1, card2|
          card1 = 'JL' if card1 == 'J' && joker_wild?
          card2 = 'JL' if card2 == 'J' && other_hand.joker_wild?
          if CARD_VALUE[card1] != CARD_VALUE[card2]
            return CARD_VALUE[card1] <=> CARD_VALUE[card2]
          end
        end

      return 0;
    else
      hand_type_value <=> other_hand.hand_type_value
    end
  end

  def joker_wild?
    is_joker_wild
  end

  def set_joker_wild
    @is_joker_wild = true
    @hand_type = parse_hand_type
    @hand_type_value = HAND_TYPE_VALUE[hand_type]
    self
  end

  private

  def parse_hand_type
    best_hand_type = parse_without_wild_joker

    if hand.include?('J') && joker_wild?
      with_joker_hand_type = parse_with_wild_joker

      if HAND_TYPE_VALUE[with_joker_hand_type] >= HAND_TYPE_VALUE[best_hand_type]
        best_hand_type = with_joker_hand_type
      end
    end

    best_hand_type
  end

  def parse_with_wild_joker
    num_jokers = hand.count('J')
    hand_tally = hand.gsub('J', '').chars.tally

    if hand_tally.values.any? { |count| count >= (5 - num_jokers) }
      :five_of_a_kind
    elsif hand_tally.values.any? { |count| count >= (4 - num_jokers) }
      :four_of_a_kind
    elsif (num_jokers == 1 && hand_tally.values.count { |count| count == 2 } == 2) || (num_jokers == 2 && hand_tally.values.count { |count| count == 2 } == 1)
      :full_house
    elsif hand_tally.values.any? { |count| count >= (3 - num_jokers)  }
      :three_of_a_kind
    elsif (num_jokers == 1 && hand_tally.values.count { |count| count == 2 } == 1) || (num_jokers == 2 && hand_tally.values.count { |count| count == 2 } == 0) || (num_jokers == 3)
      :two_pairs
    elsif hand_tally.values.any? { |count| count >= (1 - num_jokers)  }
      :one_pair
    else
      :high_card
    end
  end

  def parse_without_wild_joker
    hand_tally = hand.chars.tally

    if hand_tally.values.any? { |count| count == 5 }
      :five_of_a_kind
    elsif hand_tally.values.any? { |count| count == 4 }
      :four_of_a_kind
    elsif (hand_tally.values.any? { |count| count == 3 } && hand_tally.values.any? { |count| count == 2 })
      :full_house
    elsif hand_tally.values.any? { |count| count == 3 }
      :three_of_a_kind
    elsif (hand_tally.values.count { |count| count == 2 } == 2)
      :two_pairs
    elsif hand_tally.values.any? { |count| count == 2 }
      :one_pair
    else
      :high_card
    end
  end
end

hands = ARGF.read.chomp.split("\n")
  .map do |line|
    hand, bid_input = line.chomp.split

    Hand.new(hand, bid_input.to_i)
  end

bid_product = hands.sort.each_with_index.sum do |hand, index|
    hand.bid_value * (index + 1)
  end

pp bid_product

joker_product = hands.map(&:set_joker_wild)
  .sort
  .each_with_index
  .sum do |hand, index|
    hand.bid_value * (index + 1)
  end

pp joker_product
