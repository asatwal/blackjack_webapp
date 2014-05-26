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


  def display_winner?(player, dealer = nil)

    dealer_win = false
    player_win = false

    if (player.total_score == CardGameUtils::BLACKJACK_SCORE)
      @winner_msg = "Blackjack! #{player.name} Won! Well done."
      player_win = true
    elsif (player.total_score > CardGameUtils::BLACKJACK_SCORE)
      @loser_msg = "#{player.name} Lost! You have busted."
      dealer_win = true
    elsif !dealer.nil? && dealer.total_score >= CardGameUtils::DEALER_MIN_SCORE
      if (dealer.total_score > CardGameUtils::BLACKJACK_SCORE)
        @winner_msg = "#{player.name} Won! Dealer has busted."
        player_win =  true
      elsif (dealer.total_score == CardGameUtils::BLACKJACK_SCORE)
        @loser_msg = "Blackjack! Dealer Won! #{player.name} Lost."
        dealer_win = true
      elsif (dealer.total_score > player.total_score)
        @loser_msg = "Dealer Won! #{player.name} Lost."
        dealer_win =  true
      elsif (dealer.total_score < player.total_score)
        @winner_msg = "#{player.name} Won! Dealer Lost."
        player_win =  true
      else
        @winner_msg = "#{player.name} and Dealer draw!"
        # No winners but must retrun sucess here to control flow
        return true
      end
    end

    if player_win 
      player.funds += session[:player_bet].to_i
    elsif dealer_win
       player.funds -= session[:player_bet].to_i
    end     

    return dealer_win || player_win
  end

end

before do
   @player_turn = false
   @dealer_turn = false
end

get '/' do

  if session[:player]
  	redirect '/player/bet'
  else
  	redirect '/player/new'
  end
end


get '/player/game' do

  deck = Deck.new

  3.times { deck.shuffle }

  player = Marshal.load(session[:player])
  dealer = Player.new(CardGameUtils::DEALER_NAME)

  player.clear_cards

  2.times do
    player.hit(deck.deal)
    dealer.hit(deck.deal)
  end

  @player_turn = true unless display_winner?(player)

  session[:deck] = Marshal.dump(deck)
  session[:dealer] = Marshal.dump(dealer)
  session[:player] = Marshal.dump(player)

  erb :play_game

end

post '/player/game/hit' do

  player = Marshal.load(session[:player])
  deck = Marshal.load(session[:deck])

  player.hit(deck.deal)

  unless display_winner?(player)
    @player_turn = true 
    @player_msg = "#{player.name} has just hit."
  end

  session[:player] = Marshal.dump(player)
  session[:deck] = Marshal.dump(deck)

  erb :play_game, layout: false

end


post '/player/game/stay' do

  dealer = Marshal.load(session[:dealer])
  player = Marshal.load(session[:player])

  unless display_winner?(player, dealer)
    @dealer_turn = true
    @player_msg = "#{player.name} decided to stay."
  else
    session[:player] = Marshal.dump(player)
  end

  erb :play_game, layout: false

end


post '/dealer/game/hit' do

  dealer = Marshal.load(session[:dealer])
  deck = Marshal.load(session[:deck])
  player = Marshal.load(session[:player])

  dealer.hit(deck.deal)

  unless display_winner?(player, dealer)
    @dealer_turn = true
    @player_msg = "Dealer has just hit."
  else
    session[:player] = Marshal.dump(player)
  end

  session[:dealer] = Marshal.dump(dealer)
  session[:deck] = Marshal.dump(deck)

  erb :play_game, layout: false

end

get '/player/bet' do
  erb :player_bet
end  

post '/player/bet' do

  player = Marshal.load(session[:player])

  if params[:player_bet].empty?
    @error = "Bet amount is required"
    halt erb :player_bet
  elsif params[:player_bet].to_i <= 0
    @error = "Bet amount must be greater than zero"
    halt erb :player_bet
  elsif params[:player_bet].to_i > player.funds
    @error = "Bet amount must be less than your funds."
    halt erb :player_bet  
  end

  session[:player_bet] = params[:player_bet].to_i

  redirect '/player/game'
end


get '/player/new' do
  erb :player_new
end

post '/player/new' do

  if params[:player_name].empty?
    @error = "Name is required"
    halt erb :player_new
  end

  player = Player.new(params[:player_name])

  session[:player] = Marshal.dump(player)

	redirect '/player/bet'
end

get '/player/game/start' do
  session.clear
  redirect '/player/new'
end


get '/player/game/new' do
	player = Marshal.load(session[:player])

  player.funds = CardGameUtils::PLAYER_INITIAL_FUNDS

  session[:player] = Marshal.dump(player)

  redirect '/player/bet'
end




