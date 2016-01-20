require 'httparty'
require 'time'
require 'byebug'

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

  def carrier(trip_num, leg_num)
    @page["trips"]["tripOption"][trip_num]["slice"][0]["segment"][leg_num]["flight"]["carrier"]
  end

  def number(trip_num, leg_num)
    @page["trips"]["tripOption"][trip_num]["slice"][0]["segment"][leg_num]["flight"]["number"]
  end

  def origin(trip_num, leg_num)
    @page["trips"]["tripOption"][trip_num]["slice"][0]["segment"][leg_num]["leg"][0]["origin"]
  end

  def destination(trip_num, leg_num)
    @page["trips"]["tripOption"][trip_num]["slice"][0]["segment"][leg_num]["leg"][0]["destination"]
  end

  def departs_on(trip_num, leg_num)
    day = @page["trips"]["tripOption"][trip_num]["slice"][0]["segment"][leg_num]["leg"][0]["departureTime"]
    day[0..9]
  end

  def departs_at(trip_num, leg_num)
    time = @page["trips"]["tripOption"][trip_num]["slice"][0]["segment"][leg_num]["leg"][0]["departureTime"]
    Time.parse(time).strftime '%I:%M %p'
  end

  def total_time(trip_num)
    minutes = @page["trips"]["tripOption"][trip_num]["slice"][0]["duration"].to_f
    hours = (minutes/60.0).round(1)
    "#{hours} hours"
  end

  def itinerary(num)
    trip_counter = num
    leg_counter = 0
    stops = []
    until @page["trips"]["tripOption"][trip_counter]["slice"][0]["segment"][leg_counter] == nil
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

  def show_results(num)
    lines = ""
    options(num).each do |trip|
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
# 
# puts Flight.new("RDU", "LAX", "2016-06-23").show_results(10)
