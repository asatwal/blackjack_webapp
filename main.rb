require 'rubygems'
require 'sinatra'
require 'pry'

require_relative 'user_responses.rb'
require_relative 'deck.rb'
require_relative 'card_game_utils.rb'
require_relative 'player.rb'
require_relative 'card.rb'

set :sessions, true

helpers do

  def get_image_name(card)

    "/images/cards/#{card.suit.downcase}_#{card.description.downcase}.jpg"
  end


  def display_winner(dealer, player)

    if (dealer.total_score > player.total_score )
      @error = "Dealer has won #{player.name}!"
    elsif (dealer.total_score < player.total_score )
      @success = "#{player.name} has won Dealer!"
    else
      @success = "#{player.name} and Dealer draw!"
    end
  end

end

before do
   @show_player_buttons = false
   @show_dealer_buttons = false
   @show_dealer_first_card = false
end

get '/' do

  if session[:player_name]
  	redirect '/player/game'
  else
  	redirect '/player/new'
  end
end

get '/player/game' do
  
  deck = Deck.new

  3.times { deck.shuffle }

  player = Player.new(session[:player_name])
  dealer = Player.new(CardGameUtils::DEALER_NAME)

  2.times do
    player.hit(deck.deal)
    dealer.hit(deck.deal)
  end

  session[:player] = Marshal.dump(player)
  session[:deck] = Marshal.dump(deck)
  session[:dealer] = Marshal.dump(dealer)

  if (player.total_score == CardGameUtils::BLACKJACK_SCORE)
    @success = "Blackjack! Well done #{player.name}! You have won"
  else
      @show_player_buttons = true
  end

  erb :play_game

end

get '/player/new' do
  erb :player_new
end

post '/player/new' do

  if params[:player_name].empty?
    @error = "Name is required"
    halt erb :player_new
  end

	session[:player_name] = params[:player_name]
	redirect '/player/game'
end

get '/player/game/new' do
	session.clear
  redirect '/player/new'
end

post '/player/game/hit' do

  player = Marshal.load(session[:player])
  deck = Marshal.load(session[:deck])

  player.hit(deck.deal)

  session[:player] = Marshal.dump(player)
  session[:deck] = Marshal.dump(deck)

  if (player.total_score > CardGameUtils::BLACKJACK_SCORE)
    @error = "Sorry #{player.name}! You have busted!"
    @show_dealer_first_card = true
  elsif (player.total_score == CardGameUtils::BLACKJACK_SCORE)
    @success = "Blackjack! Well done #{player.name}! You have won"
    @show_dealer_first_card = true
  else
     @show_player_buttons = true
    @success = "#{session[:player_name]} has just hit!"
  end

  erb :play_game

end


post '/player/game/stay' do

  dealer = Marshal.load(session[:dealer])
  player = Marshal.load(session[:player])

  @show_dealer_first_card = true

  if (dealer.total_score >= CardGameUtils::DEALER_MIN_SCORE)
    # Game over
    display_winner(dealer, player)
  else
    @show_dealer_buttons = true
    @success = "#{session[:player_name]} decided to stay!"
  end



  erb :play_game

end


post '/dealer/game/hit' do

  dealer = Marshal.load(session[:dealer])
  deck = Marshal.load(session[:deck])
  player = Marshal.load(session[:player])

  @show_dealer_first_card = true

  dealer.hit(deck.deal)

  if (dealer.total_score > CardGameUtils::BLACKJACK_SCORE)
    @error = "Dealer has busted!"
  elsif (dealer.total_score == CardGameUtils::BLACKJACK_SCORE)
    @success = "Blackjack! Dealer has won!"
  elsif (dealer.total_score < CardGameUtils::DEALER_MIN_SCORE)
    @success = "Dealer has just hit!"
    @show_dealer_buttons = true
  else
    # Dealer min score reached - Gamover
    display_winner(dealer, player)
  end

  session[:dealer] = Marshal.dump(dealer)
  session[:deck] = Marshal.dump(deck)



  erb :play_game

end


