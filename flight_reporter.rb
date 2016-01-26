require './flight.rb'
require './flight_parser.rb'

class FlightReporter

  attr_reader :parsed_flight, :number_of_results

  def initialize(parsed_flight, number_of_results)
    @parsed_flight = parsed_flight.options(number_of_results)
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
    lines
  end
end

# puts FlightReporter.new((FlightParser.new(Flight.new("RDU", "SFO", "2016-06-23"))), 5).show_results
