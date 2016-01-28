require 'minitest/autorun'
require 'minitest/pride'
require './flight_fetcher.rb'
require './flight_parser.rb'
require './flight_reporter.rb'
require './flight_analyst.rb'

class FlightFetcher
  def get_data
    JSON.parse(File.open('./mock_flight.json').read)
  end
end

class FlightTest < Minitest::Test

  def setup
    @flight = FlightFetcher.new("RDU", "SFO", "2015-06-01")
    @flight_parser = FlightParser.new(@flight)
    @flight_analyst = FlightAnalyst.new(@flight_parser, 10)
    @flight_reporter = FlightReporter.new(@flight_parser, @flight_analyst, 1)
  end

  def test_can_be_created_with_three_inputs
    assert FlightFetcher.new("RDU", "SFO", "2015-06-01")
  end

  def test_can_get_info
    assert_equal "$281.99", @flight_parser.price(0)
    assert_equal "B6", @flight_parser.carrier(0, 0)
    assert_equal "1186", @flight_parser.number(0, 0)
  end

  def test_can_get_origin_and_destination
    assert_equal "RDU", @flight_parser.origin(0, 0)
    assert_equal "JFK", @flight_parser.destination(0, 0)
  end

  def test_itinerary
    assert_equal [{"leg"=>1, "origin"=>"RDU", "destination"=>"JFK",
      "flight_number"=>"B6 1186", "departure_time"=>"07:20 PM"},
      {"leg"=>2, "origin"=>"JFK", "destination"=>"LAX", "flight_number"=>"B6 2023",
         "departure_time"=>"10:45 PM"}, "9.4 hours", "$281.99"], @flight_parser.itinerary(0)
  end

  def test_departs_at
    assert_equal "07:20 PM", @flight_parser.departs_at(0, 0)
  end

  def test_total_time
    assert_equal "9.4 hours", @flight_parser.total_time(0)
  end

  def test_options
    assert_equal 3, @flight_parser.options(3).length
    refute_equal @flight_parser.options(3)[0], @flight_parser.options(3)[1]
  end

  def test_format
    assert_equal "$281.99 || 9.4 hours || RDU -> JFK @ 07:20 PM || JFK -> LAX @ 10:45 PM || JetBlue\n", @flight_reporter.show_results
  end

  def test_average
    assert_equal 350, @flight_analyst.average_price
  end

  def test_median
    assert_equal 357, @flight_analyst.median
  end

  def test_low
    assert_equal 282, @flight_analyst.low
  end

  def test_show_stats
    assert_equal "Average Price: 350\nMedian Price: 357\nLow Price: 282\n",
    @flight_reporter.show_stats
  end

end
