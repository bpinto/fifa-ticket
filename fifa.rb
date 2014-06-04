require 'oj'
require 'net/http'

MATCHES = {
  'IMT11' => 'Argentina vs Bosnia-Herzegovina',
  'IMT19' => 'Spain vs Chile',
  'IMT31' => 'Belgium vs Russia',
  'IMT42' => 'Ecuador vs France',
  'IMT50' => '1C vs 2D',
  'IMT58' => 'Match 58',
  'IMT64' => 'FINAL',
}

CATEGORIES = {
  '1'   => 'CAT1',
  '2'   => 'CAT2',
  '3'   => 'CAT3',
  '4'   => 'CAT4',
  #'5'   => 'W',
  #'13'  => 'M',
  #'14'  => 'O',
}

while true do
  begin
    uri      = URI('https://fwctickets.fifa.com/TopsAkaCalls/Calls.aspx/getRefreshChartAvaDem?l=en&c=BRA')
    response = Net::HTTP.get(uri)

    json = Oj.load response
    data = Oj.load json['d']['data']

    matches = data['BasicCodes']['PRODUCTPRICES'].select do |match|
      CATEGORIES.keys.include?(match['PRPCategoryId']) && MATCHES.keys.include?(match['PRPProductId'])
    end

    tickets_available = false
    MATCHES.each do |match_code, match_name|
      seats_from_same_game = matches.select { |m| m['PRPProductId'] == match_code }

      availability = CATEGORIES.map do |cat_code, cat_name|
        seats_per_category = seats_from_same_game.find { |m| m['PRPCategoryId'] == cat_code }
        tickets_available  = true if seats_per_category['Quantity'].to_i > 0 && cat_code == '4'
        "#{cat_name} #{seats_per_category['Quantity'].to_i}"
      end

      puts "#{match_name}: #{availability.join(' / ')}" if tickets_available
    end

    if tickets_available
      puts
      system('say "ingresso para o jogo da fifa disponivel"')
    else
      print '.'
    end
  rescue
    puts 'Error'
  ensure
    sleep 180
  end
end

