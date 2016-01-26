require './flight_fetcher.rb'
require 'time'

class FlightParser
  attr_reader :results

  def initialize(flight)
    @results = flight.itineraries
  end

  def price(trip_num)
    cost = results["trips"]["tripOption"][trip_num]["saleTotal"]
    new_cost = cost[3..-1]
    "$#{new_cost}"
  end

  def carrier(trip_num, leg_num)
    results["trips"]["tripOption"][trip_num]["slice"][0]["segment"][leg_num]["flight"]["carrier"]
  end

  def number(trip_num, leg_num)
    results["trips"]["tripOption"][trip_num]["slice"][0]["segment"][leg_num]["flight"]["number"]
  end

  def origin(trip_num, leg_num)
    results["trips"]["tripOption"][trip_num]["slice"][0]["segment"][leg_num]["leg"][0]["origin"]
  end

  def destination(trip_num, leg_num)
    results["trips"]["tripOption"][trip_num]["slice"][0]["segment"][leg_num]["leg"][0]["destination"]
  end

  def departs_on(trip_num, leg_num)
    day = results["trips"]["tripOption"][trip_num]["slice"][0]["segment"][leg_num]["leg"][0]["departureTime"]
    day[0..9]
  end

  def departs_at(trip_num, leg_num)
    time = results["trips"]["tripOption"][trip_num]["slice"][0]["segment"][leg_num]["leg"][0]["departureTime"]
    Time.parse(time).strftime '%I:%M %p'
  end

  def total_time(trip_num)
    minutes = results["trips"]["tripOption"][trip_num]["slice"][0]["duration"].to_f
    hours = (minutes/60.0).round(1)
    "#{hours} hours"
  end

  def itinerary(num)
    trip_counter = num
    leg_counter = 0
    stops = []
    until results["trips"]["tripOption"][trip_counter]["slice"][0]["segment"][leg_counter] == nil
      next_stop = {}
      next_stop["leg"] = leg_counter+1
      next_stop["origin"] = origin(trip_counter, leg_counter)
      next_stop["destination"] = destination(trip_counter, leg_counter)
      next_stop["flight_number"] = "#{carrier(trip_counter, leg_counter)} #{number(trip_counter, leg_counter)}"
      next_stop["departure_time"] = "#{departs_at(trip_counter, leg_counter)}"
      stops << next_stop
      leg_counter += 1
    end
    stops << total_time(trip_counter)
    stops << price(trip_counter)
    stops
  end

  def options(num)
    counter = 0
    trips = []
    until counter == num
      trips<<itinerary(counter)
      counter += 1
    end
    trips
  end
end
