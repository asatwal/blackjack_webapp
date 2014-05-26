
require_relative 'card_game_utils.rb'

require_relative 'card.rb'

class Player

  attr_accessor :name
  attr_accessor :cards
  attr_accessor :funds


  def initialize(name)
    @cards = []
    @name = name
    @funds = CardGameUtils::PLAYER_INITIAL_FUNDS
  end


  def hit(card)

    if @cards.empty?
      @cards[0] = card
    else
      @cards.push(card)
    end
  end

  def clear_cards

    if !@cards.empty?
      @cards.clear
    end
  end

  def total_score
    score = 0

    @cards.each { |card| score += card.value }

    return score if score <= CardGameUtils::BLACKJACK_SCORE

    # Have gone bust
    # - check if we have any Aces with high value and change to low value 
    @cards.count {|card| card.value == 11 }.times do 
      score -= 10
      break if score <= CardGameUtils::BLACKJACK_SCORE
    end

    score

  end

  def to_s
    str = "#{@name} Cards: "
    @cards.each { |card| str += card.to_s + ' '}
    str += "Total score: #{total_score}"
  end

end

