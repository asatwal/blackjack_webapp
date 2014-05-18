
require_relative 'card.rb'

class Deck

  def initialize
    reset
  end

  def reset

    @cards = []

    Card::SUITS.each do |suit|
      (1..13).each do |i|
        @cards << Card.new(suit, i)
      end
    end
  end

  def deal
    @cards.pop
  end

  def shuffle
    # Use time in micro seconds and the seed for random number generation
    @cards.shuffle!(random: Random.new(Time::now.usec))
  end

  def to_s
    str = "Deck of Cards"
    @cards.each { |card| str += card + ' ' }
  end
end
