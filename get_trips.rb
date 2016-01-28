require './flight_fetcher.rb'
require './flight_parser.rb'
require './flight_reporter.rb'
require './flight_analyst.rb'


destinations = ["SFO", "LAX", "PHX", "LAS"]
to_west_dates = ["2016-06-22", "2016-06-23"]
to_east_dates = ["2016-07-02", "2016-07-01"]
to_home_dates = ["2016-07-04", "2016-07-05"]

destinations.each do |dest|
  to_west_dates.each do |date|
    @flight = FlightFetcher.new("RDU", dest, date)
    @flight_parser = FlightParser.new(@flight)
    @flight_analyst = FlightAnalyst.new(@flight_parser, 10)
    @flight_reporter = FlightReporter.new(@flight_parser, @flight_analyst, 10)
    puts "RDU to #{dest} on #{date}"
    puts "*" * 30
    puts @flight_reporter.show_results
    puts @flight_reporter.show_stats
    puts
  end
end

destinations.each do |dest|
  to_east_dates.each do |date|
    @flight = FlightFetcher.new(dest, "NYC", date)
    @flight_parser = FlightParser.new(@flight)
    @flight_analyst = FlightAnalyst.new(@flight_parser, 10)
    @flight_reporter = FlightReporter.new(@flight_parser, @flight_analyst, 10)
    puts "#{dest} to NYC on #{date}"
    puts "*" * 30
    puts @flight_reporter.show_results
    puts @flight_reporter.show_stats
    puts
  end
end

to_home_dates.each do |date|
  @flight = FlightFetcher.new("NYC", "RDU", date)
  @flight_parser = FlightParser.new(@flight)
  @flight_analyst = FlightAnalyst.new(@flight_parser, 10)
  @flight_reporter = FlightReporter.new(@flight_parser, @flight_analyst, 10)
  puts "NYC to RDU on #{date}"
  puts "*" * 30
  puts @flight_reporter.show_results
  puts @flight_reporter.show_stats
  puts
end
