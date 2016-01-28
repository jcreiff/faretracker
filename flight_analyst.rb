require 'byebug'

class FlightAnalyst

  def initialize(parsed_flight, number_of_results)
    @parsed_flight = parsed_flight.options(number_of_results)
    @number_of_results = number_of_results
  end

  def prices
    @parsed_flight.map{|flight| flight[-1][1..-1].to_f.ceil}
  end

  def average_price
    prices.reduce(:+)/@number_of_results
  end

  def median
    if @number_of_results.odd?
      prices[@number_of_results/2]
    else
      prices[(@number_of_results/2 - 1)..@number_of_results/2].reduce(:+)/2
    end
  end

  def low
    prices[0]
  end
end
