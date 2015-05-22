require 'nokogiri'
require 'open-uri'
require 'json'

BOM_BASE_URL = 'http://www.bom.gov.au'
FIO_BASE_URL = 'https://api.forecast.io/forecast'

WIND_DIRS = %i{ N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW }.freeze
WIND_DIR_MAPPINGS = WIND_DIRS.each_with_index.inject({}) { |m, (dir, index)| m[dir] = index * 360.0 / WIND_DIRS.size; m }.freeze

def load_bom_info_table
  melb_doc = Nokogiri::HTML(open("#{BOM_BASE_URL}/vic/observations/melbourne.shtml"))
  melb_doc.css("#tMELBOURNE").first
end

namespace :weather do
  # Update the locations in the DB from BOM. Marks any locations that have disappeared as inactive.
  task :update_locations => :environment do
    # Get the list of locations from BOM.
    info_table = load_bom_info_table
    info_table.xpath("./tbody/tr/th/a").each do |location_node|
      # Find the location's information
      location_doc = Nokogiri.HTML(open("#{BOM_BASE_URL}#{location_node.attr :href}"))
      station_details = location_doc.css(".stationdetails").first.text
      station_details.match(/Lat:\s*(-?\d+\.\d+)\s+Lon:\s*(-?\d+\.\d+)/)
      name = location_node.text
      lat = $1.to_f
      lon = $2.to_f

      # Update the location in the DB.
      location = Location.find_or_initialize_by(loc_id: name)
      location.lat = lat
      location.lon = lon
      location.save if location.changed?
    # fix me, do we need location_active?
    end
  end

  # Scrape the BOM site for data.
  task :scrape_bom => :environment do
    info_table = load_bom_info_table
    info_table.xpath("./tbody/child::*[child::th/a]").each do |row|
      name = row.xpath("./th/a").text
      if location = Location.find_by(name: name, active: true)
        # Find the information.
        temp = row.xpath("./td[contains(@headers, 'obs-temp')]").text.to_f
        rain = row.xpath("./td[contains(@headers, 'obs-rainsince9am')]").text.to_f
        wind_speed = row.xpath("./td[contains(@headers, 'obs-wind-spd-kph')]").text.to_f
        wind_dir_name = row.xpath("./td[contains(@headers, 'obs-wind-dir')]").text
        wind_dir = WIND_DIR_MAPPINGS[wind_dir_name.to_sym]

        # Create a new reading.
        reading = Reading.new(
          temperature: temp,
          rainfall: rain,
          wind_speed: wind_speed,
          wind_dir: wind_dir,
          timestamp: Time.now
        )
        measurement = Measurement.new(timestamp: Time.now)
        measurement.location = location
        temperature = Temperature.new(temp: temp)
        temperature.measurement = measurement
        rainfall = Rainfall.new(precip: rain)
        rainfall.measurement = measurement
        wind_speed = Wind_speed.new(speed: wind_speed)
        wind_speed.measurement = measurement
        wind_direction = Wind_direction.new(bearing: wind_dir)
        wind_direction.measurement = measurement
        measurement.save
        temperature.save
        rainfall.save
        wind_speed.save
        wind_direction.save
      end
    end
  end

  # scrape the forecast for particular position
  task :scrape_forecast => :environment do
  end
end