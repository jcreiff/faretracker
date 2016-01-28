require './flight_fetcher.rb'
require './flight_parser.rb'
require './flight_analyst.rb'

class FlightReporter

  attr_reader :parsed_flight, :number_of_results

  def initialize(parsed_flight, flight_analyst, number_of_results)
    @parsed_flight = parsed_flight.options(number_of_results)
    @flight_analyst = flight_analyst
    @number_of_results = number_of_results
  end


  def show_results
    lines = ""
    @parsed_flight.each do |trip|
      lines<<"#{trip[-1]}"
      lines<<" || #{trip[-2]}"
      lines<<" || #{trip[0]["origin"]} -> #{trip[0]["destination"]} @ #{trip[0]["departure_time"]}"
      lines<<" || #{trip[1]["origin"]} -> #{trip[1]["destination"]} @ #{trip[1]["departure_time"]}" unless trip[1].nil?
      lines<<" || #{trip[0]["flight_number"][0..1]}"
      lines<<"\n"
    end
    translate(lines)
  end

  def translate(text)
    airline_codes.keys.each do |code|
      text.gsub!(code, airline_codes[code])
    end
    text
  end

  def airline_codes
    {"AA"=>"American", "B6"=>"JetBlue", "DL"=>"Delta", "F9"=>"Frontier", "FL"=>"AirTran",
      "WN"=>"Southwest","UA"=>"United"}
  end

  def show_stats
    stats = ""
    stats<<"Average Price: #{@flight_analyst.average_price}\n"
    stats<<"Median Price: #{@flight_analyst.median}\n"
    stats<<"Low Price: #{@flight_analyst.low}\n"
    stats
  end
end
