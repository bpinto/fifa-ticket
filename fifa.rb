require 'oj'
require 'net/http'

while true do
  begin
    uri      = URI('https://fcctickets.fifa.com/TopsAkaCalls/Calls.aspx/getBasicDataAvaDem?l=en&c=BRA')
    response = Net::HTTP.get(uri)

    json = Oj.load response
    data = Oj.load json['d']['data']

    final_match = data['BasicCodes']['AVAILABILITY'].find do |match|
      match['ProductID'] == 'IMT16' && match['CategoryName'] == 'CAT4'
    end

    puts "Quantidade de assentos disponíveis: #{final_match['Quantity'].to_i}"
    final_match_available = final_match['Quantity'].to_i > 0

    system('say "ingresso para o jogo da fifa"') if final_match_available
  rescue
    puts 'Error'
  ensure
    sleep 300
  end
end

