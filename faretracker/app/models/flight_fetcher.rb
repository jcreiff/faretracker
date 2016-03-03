require 'httparty'
require 'byebug'

class FlightFetcher
  attr_reader :itineraries

  def initialize(start_code, end_code, date)
    @start_code = start_code
    @end_code = end_code
    @date = date
    @itineraries = get_data
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

end
