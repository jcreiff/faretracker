require 'httparty'
require 'time'

class Flight

  def initialize(start_code, end_code, date)
    @start_code = start_code
    @end_code = end_code
    @date = date
    @page = get_data
  end


  def get_data
    HTTParty.post("https://www.googleapis.com/qpxExpress/v1/trips/search?key=#{ENV["GOOGLE_KEY"]}",
    :body =>  {
        "request": {
          "passengers": {
            "kind": "qpxexpress#passengerCounts",
            "adultCount": 1,
            "childCount": 0,
            "infantInLapCount": 0,
            "infantInSeatCount": 0,
            "seniorCount": 0
          },
          "slice": [
            {
              "kind": "qpxexpress#sliceInput",
              "origin": "#{@start_code}",
              "destination": "#{@end_code}",
              "date": "#{@date}",
              "maxStops": 1,
              "preferredCabin": "COACH",
            }
          ],
          "refundable": false,
          "solutions": 10
        }
      }.to_json,
      :headers => { 'Content-Type' => 'application/json' })
  end

  def price(num)
    cost = @page["trips"]["tripOption"][num]["saleTotal"]
    new_cost = cost[3..-1]
    "$#{new_cost}"
  end

  def carrier(num)
    @page["trips"]["tripOption"][0]["slice"][0]["segment"][num]["flight"]["carrier"]
  end

  def number(num)
    @page["trips"]["tripOption"][0]["slice"][0]["segment"][num]["flight"]["number"]
  end

  def origin(num)
    @page["trips"]["tripOption"][0]["slice"][0]["segment"][num]["leg"][0]["origin"]
  end

  def destination(num)
    @page["trips"]["tripOption"][0]["slice"][0]["segment"][num]["leg"][0]["destination"]
  end

  def departs_on(num)
    day = @page["trips"]["tripOption"][0]["slice"][0]["segment"][num]["leg"][0]["departureTime"]
    day[0..9]
  end

  def departs_at(num)
    time = @page["trips"]["tripOption"][0]["slice"][0]["segment"][num]["leg"][0]["departureTime"]
    Time.parse(time).strftime '%I:%M %p'
  end

  def total_time(num)
    minutes = @page["trips"]["tripOption"][num]["slice"][0]["duration"].to_f
    hours = (minutes/60.0).round(2)
    "#{hours} hours"
  end

  def itinerary(num)
    trip_counter = num
    leg_counter = 0
    stops = []
    until @page["trips"]["tripOption"][trip_counter]["slice"][0]["segment"][leg_counter] == nil
      next_stop = {}
      next_stop["leg"] = leg_counter+1
      next_stop["origin"] = origin(leg_counter)
      next_stop["destination"] = destination(leg_counter)
      next_stop["flight_number"] = "#{carrier(leg_counter)} #{number(leg_counter)}"
      next_stop["departure_time"] = "#{departs_on(leg_counter)} at #{departs_at(leg_counter)}"
      stops << next_stop
      leg_counter += 1
    end
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
