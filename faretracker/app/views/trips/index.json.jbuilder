json.array!(@trips) do |trip|
  json.extract! trip, :id, :origin, :destination, :date, :active
  json.url trip_url(trip, format: :json)
end
