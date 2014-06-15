require 'oj'
require 'net/http'
require 'net/https'
require 'mandrill'
require 'terminal-table'

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

# Set MANDRILL_APIKEY environment variable
def send_email(table)
  mandrill = Mandrill::API.new

  message = {
    subject: 'Ingressos para a Copa do Mundo',
    from_name: 'TODO',
    text: table.to_s,
    to: [
      { email: 'TODO', name: 'TODO' },
    ],
    from_email: 'TODO'
  }

  mandrill.messages.send message
end

def send_notification(table)
  url = URI.parse('https://api.pushover.net/1/messages.json')
  req = Net::HTTP::Post.new(url.path)
  req.set_form_data({
    token: 'TODO',
    user: 'TODO',
    message: 'Ingressos para a Copa do Mundo',
  })
  res = Net::HTTP.new(url.host, url.port)
  res.use_ssl = true
  res.verify_mode = OpenSSL::SSL::VERIFY_PEER
  res.start {|http| http.request(req) }
end

while true do
  begin
    uri      = URI('https://fwctickets.fifa.com/TopsAkaCalls/Calls.aspx/getRefreshChartAvaDem?l=en&c=BRA')
    response = Net::HTTP.get(uri)

    json = Oj.load response
    data = Oj.load json['d']['data']

    matches = data['BasicCodes']['PRODUCTPRICES'].select do |match|
      CATEGORIES.keys.include?(match['PRPCategoryId']) && MATCHES.keys.include?(match['PRPProductId'])
    end

    table = Terminal::Table.new
    table.headings = ['Jogo'] + CATEGORIES.values

    MATCHES.each do |match_code, match_name|
      seats_from_match = matches.select { |m| m['PRPProductId'] == match_code }.
        sort { |m| m['PRPCategoryId'].to_i }

      if seats_from_match.any? { |seat| seat['Quantity'].to_i > 10 }
        table.add_row [match_name, *seats_from_match.map { |seat| seat['Quantity'].to_i }]
      end
    end

    if table.rows.any?
      puts "Notifications sent\n"
      send_notification table
      send_email table
      sleep 300
    else
      print '.'
    end
  rescue
    puts 'Error'
  ensure
    sleep 5
  end
end

