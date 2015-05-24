require 'nokogiri'
require 'open-uri'
require 'json'

BOM_BASE_URL = 'http://www.bom.gov.au'
FIO_BASE_URL = 'https://api.forecast.io/forecast'

WIND_DIRS = %i{ N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW }.freeze
WIND_DIR_MAPPINGS = WIND_DIRS.each_with_index.inject({}) { |m, (dir, index)| m[dir] = index * 360.0 / WIND_DIRS.size; m }.freeze

def load_bom_info_table(suffix)
  tables = []
  melb_doc = Nokogiri::HTML(open("#{BOM_BASE_URL}#{suffix}"))
  melb_doc.css("table").each{|t| tables << t}
  return tables
end

def load_bom_index
  data = Nokogiri::HTML(open(BOM_BASE_URL))
  urls = data.css("a")
  suffix = []

  urls.each do |node|
    url = node.attr :href
    res = url.match(/\/[a-z]+\/observations\/[a-z]+all.shtml\?ref=hdr/)
    if res == nil
      res = url.match(/\/[a-z]+\/observations\/canberra.shtml\?ref=hdr/)
    end
    if res != nil
      suffix << res
    end
  end

  res=[]

  suffix.each do |s|
    tables = load_bom_info_table(s)
    tables.each{|t| res << t}
  end

  return res
end

namespace :weather do
  # Update the locations in the DB from BOM. Marks any locations that have disappeared as inactive.
  task :update_locations => :environment do
    # Get the list of locations from BOM.
    index = load_bom_index
    index.each do |info_table|
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
      end
    end
  end

  # Scrape the BOM site for data.
  task :scrape_bom => :environment do
    index = load_bom_index
    index.each do |info_table|
      info_table.xpath("./tbody/child::*[child::th/a]").each do |row|
        name = row.xpath("./th/a").text
        if location = Location.find_by(loc_id: name)
          # Find the information.
          time_details = row.xpath("./td[contains(@headers, 'obs-datetime')]").text
          time_details.match(/\d{1,2}\/(\d{2}):(\d{2})([ap]m)/)
          if $3 == "am" 
            if $1 == "12"
              hour = 0
            else
              hour = $1.to_i
            end
          elsif $3 == "pm"
            if $1 == "12"
              hour = 12
            else
              hour = $1.to_i + 12
            end
          end
          min = $2.to_i
          t=Time.now
          timestamp = Time.new(t.year, t.month, t.day, hour, min, 0)
          temp = row.xpath("./td[contains(@headers, 'obs-temp')]").text.to_f
          rain = row.xpath("./td[contains(@headers, 'obs-rainsince9am')]").text.to_f
          wind_speed = row.xpath("./td[contains(@headers, 'obs-wind-spd-kph')]").text.to_f
          wind_dir_name = row.xpath("./td[contains(@headers, 'obs-wind-dir')]").text
          wind_dir = WIND_DIR_MAPPINGS[wind_dir_name.to_sym]

          wdate = location.wdates.find_or_initialize_by(date: Date.today.strftime('%d-%m-%Y'))
          wdate.save if wdate.changed?
          # Create a new measurement.
          measurement = wdate.measurements.find_or_initialize_by(timestamp: timestamp)
          if measurement.changed?
            temperature = Temperature.new(temp: temp)
            temperature.measurement = measurement
            rainfall = Rainfall.new(precip: rain)
            rainfall.measurement = measurement
            wind_speed = WindSpeed.new(speed: wind_speed)
            wind_speed.measurement = measurement
            wind_direction = WindDirection.new(bearing: wind_dir)
            wind_direction.measurement = measurement
            measurement.save
            temperature.save
            rainfall.save
            wind_speed.save
            wind_direction.save
          end
        end
      end
    end
  end

  # scrape the forecast for particular position
  task :scrape_forecast => :environment do
  end
end
