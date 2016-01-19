require 'minitest/autorun'
require 'minitest/pride'
require './flight.rb'

class Flight
  private def get_data
    JSON.parse(File.open('./mock_flight.json').read)
  end
end

class FlightTest < Minitest::Test

  def setup
    @flight = Flight.new("RDU", "SFO", "2015-06-01")
  end

  def test_can_be_created_with_three_inputs
    assert Flight.new("RDU", "SFO", "2015-06-01")
  end

  def test_can_get_info
    assert_equal "$281.99", @flight.price(0)
    assert_equal "B6", @flight.carrier(0, 0)
    assert_equal "1186", @flight.number(0, 0)
  end

  def test_can_get_origin_and_destination
    assert_equal "RDU", @flight.origin(0, 0)
    assert_equal "JFK", @flight.destination(0, 0)
  end

  def test_itinerary
    assert_equal [{"leg"=>1, "origin"=>"RDU", "destination"=>"JFK",
      "flight_number"=>"B6 1186", "departure_time"=>"2016-06-23 at 07:20 PM"},
      {"leg"=>2, "origin"=>"JFK", "destination"=>"LAX", "flight_number"=>"B6 2023",
         "departure_time"=>"2016-06-23 at 10:45 PM"}, "$281.99"], @flight.itinerary(0)
  end

  def test_departs_at
    assert_equal "07:20 PM", @flight.departs_at(0, 0)
  end

  def test_total_time
    assert_equal "9.37 hours", @flight.total_time(0)
  end

  def test_options
    assert_equal 3, @flight.options(3).length
    refute_equal @flight.options(3)[0], @flight.options(3)[1]
  end

end
