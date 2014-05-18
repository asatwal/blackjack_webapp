class Card
  SUITS = ['Clubs', 'Diamonds', 'Hearts', 'Spades']

  # All Cards have a Card ID to identifier them within the suit
  # - IDs must be unique
  # - Cards 1..10 have ID 1..10 respectively
  # - Others IDs are defined below


  ACE_ID    = 1
  JACK_ID   = 11
  QUEEN_ID  = 12
  KING_ID   = 13

  PICTURE_CARD_DESCRIPTION = { ACE_ID => 'Ace', JACK_ID => 'Jack', QUEEN_ID => 'Queen', KING_ID => 'King' }

  attr_accessor :suit, :id

  def initialize(suit, id)
    @suit = suit
    @id = id
  end

  def value
    if id == ACE_ID
      value = 11
    elsif id >= JACK_ID
      value = 10
    else
      # All other IDs (2..10) reflect the card value
      value = id 
    end
  end

  def description
    if PICTURE_CARD_DESCRIPTION.key?(id)
      PICTURE_CARD_DESCRIPTION[id]
    else
      id.to_s
    end
  end

  def to_s
    if PICTURE_CARD_DESCRIPTION.key?(id)
      "#{PICTURE_CARD_DESCRIPTION[id]} of #{suit}"
    else
      "#{id} of #{suit}"
    end
  end

  def set_low_ace
    @id = ACE_LOW_ID if id == ACE_HIGH_ID
  end
end
