class Hand
  attr_reader :cards

  def initialize(*cards)
    @cards = cards
  end

  def draw
    cards.shift
  end

  def receive(*won_cards)
    cards.push(*won_cards)
  end
end

class WarGame
  attr_reader :player1, :player2

  def initialize(player1_hand, player2_hand)
    @player1 = Hand.new(*player1_hand)
    @player2 = Hand.new(*player2_hand)
  end

  def play
    until player1.cards.empty? || player2.cards.empty?
      p1_card = player1.draw
      p2_card = player2.draw

      if p1_card > p2_card
        player1.receive(p1_card, p2_card)
      elsif p2_card > p1_card
        player2.receive(p2_card, p1_card)
      else
        raise "equality?!?"
      end
    end

    return player1.cards unless player1.cards.empty?
    return player2.cards unless player2.cards.empty?

    raise "NO WINNER?!?!@?"
  end
end

class RecursiveCombat
  attr_reader :player1, :player2, :recursive, :prev_hands, :debug

  def initialize(player1_hand, player2_hand, recursive: false, debug: false)
    @player1 = Hand.new(*player1_hand)
    @player2 = Hand.new(*player2_hand)
    @recursive = recursive
    @prev_hands = {}
    @debug = debug
  end

  def play
    count = 0
    until player1.cards.empty? || player2.cards.empty?
      count += 1
      pp prev_hands if debug
      pp player1.cards if debug
      pp player2.cards if debug


      # if the hands have been the same in the past, abort
      if previously_seen_hands?
        player2.cards.clear
        next
      end

      remember_current_hands

      # Draw a card
      p1_card = player1.draw
      p2_card = player2.draw

      # End the game if either player doesn't have enough cards to play further
      if player1.cards.count < p1_card || player2.cards.count < p2_card
        if p1_card > p2_card
          player1.receive(p1_card, p2_card)
        elsif p2_card > p1_card
          player2.receive(p2_card, p1_card)
        end
        next
      end

      # start a subgame
      case RecursiveCombat.new(player1.cards.take(p1_card), player2.cards.take(p2_card), recursive: true, debug: debug).play
      when :player1
        player1.receive(p1_card, p2_card)
      when :player2
        player2.receive(p2_card, p1_card)
      else
        raise "unknown winner of subgame"
      end
    end

    # handle game win
    if recursive
      return :player1 unless player1.cards.empty?
      return :player2 unless player2.cards.empty?
    end

    return player1.cards unless player1.cards.empty?
    return player2.cards unless player2.cards.empty?

    raise "NO WINNER?!?!@?"
  end

  def previously_seen_hands?
    prev_hands[[*player1.cards, :div, *player2.cards]]
  end

  def remember_current_hands
    prev_hands[[*player1.cards, :div, *player2.cards]] = true
  end
end

player1_hand, player2_hand = File.read(ARGV[0]).chomp.split("\n\n").map do |player_data|
  _, *cards = player_data.split("\n")
  cards.map(&:to_i)
end

WarGame
  .new(player1_hand, player2_hand)
  .play
  .reverse
  .each
  .with_index(1)
  .sum do |card, index|
    card * index
  end
  .then { |sum| puts "Combat Score: #{sum}" }

RecursiveCombat
  .new(player1_hand, player2_hand, debug: false)
  .play
  .reverse
  .each
  .with_index(1)
  .sum do |card, index|
    card * index
  end
  .then { |sum| puts "RecursiveCombat Score: #{sum}" }
