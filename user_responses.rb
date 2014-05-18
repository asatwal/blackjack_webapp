
module UserResponses

  def get_player_reponse?(display_text)

    puts "#{display_text} ? (Y/N)"
    response = ''

    loop do 
      response =  gets.chomp.upcase
      break if ['Y', 'N'].include?(response)
      puts "Invalid Input"
    end

    response.eql?('Y')
  end
end