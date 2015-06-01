require 'nokogiri'
require 'open-uri'
require 'json'
require 'csv.rb'

BOM_BASE_URL = 'http://www.bom.gov.au'
FIO_BASE_URL = 'https://api.forecast.io/forecast'
# API
GOOGLE_API_KEY = "AIzaSyDnMNUm6C1VTnyKNfCdp_ScXuEX1FZZnS8"
GOOGLE_BASE_URL = "https://maps.googleapis.com/maps/api/geocode/json?latlng="


WIND_DIRS = %i{ N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW }.freeze
WIND_DIR_MAPPINGS = WIND_DIRS.each_with_index.inject({}) { |m, (dir, index)| m[dir] = index * 360.0 / WIND_DIRS.size; m }.freeze

def load_bom_info_table(suffix)
  tables = []
  begin
    melb_doc = Nokogiri::HTML(open("#{BOM_BASE_URL}#{suffix['suffix']}"))
  rescue
    return nil
  else
    melb_doc.css("table").each{|t| tables << {"state"=>suffix['state'],"node"=>t}}
    return tables
  end
end

def load_bom_index
  data = Nokogiri::HTML(open(BOM_BASE_URL))
  urls = data.css("a")
  suffix = []

  urls.each do |node|
    url = node.attr :href
    res = url.match(/\/([a-z]+)\/observations\/[a-z]+all.shtml\?ref=hdr/)
    if res != nil
      suffix << {"state"=>$1,"suffix"=>res.to_s}
    end
  end

  result=[]

  suffix.each do |s|
    tables = load_bom_info_table(s)
    if tables != nil
      tables.each{|t| result << t}
    end
  end
  return result
end

namespace :weather do
  # Update the locations in the DB from BOM. Marks any locations that have disappeared as inactive.
  task :update_locations => :environment do
    # Get the list of locations from BOM.
    index = load_bom_index
    index.each do |info_table|
      info_table['node'].xpath("./tbody/tr/th/a").each do |location_node|
        # Find the location's information
        begin 
          location_doc = Nokogiri.HTML(open("#{BOM_BASE_URL}#{location_node.attr :href}"))
        rescue 
          nil
        else
          name = location_node.text.gsub(/\s+/,"")
          station_details = location_doc.css(".stationdetails").first.text
          station_details.match(/Lat:\s*(-?\d+\.\d+)\s+Lon:\s*(-?\d+\.\d+)/)
          state = info_table['state']
          lat = $1.to_f
          lon = $2.to_f

          # Update the location in the DB.
          location = Location.find_or_initialize_by(loc_id: name, loc_type: "station")
          location.lat = lat
          location.lon = lon
          location.active = true 
          location.state = state
          location.save if location.changed?
        end
      end
    end
  end

  # Scrape the BOM site for data.
  task :scrape_bom => :environment do
    index = load_bom_index
    index.each do |info_table|
      tid = info_table['node'].attr :id
      info_table['node'].xpath("./tbody/child::*[child::th/a]").each do |row|
        name = row.xpath("./th/a").text.gsub(/\s+/,"")
        if name == "Canberra"
          byebug
        end
        location = Location.find_by(loc_id: name, loc_type: "station")
        if location == nil || tid == nil
          nil
        else
          # Find the information.
          time_details = row.xpath("./td[contains(@headers, '#{tid}-datetime')]").text
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
          else
            byebug
          end
          min = $2.to_i
          t=Time.now
          timestamp = Time.new(t.year, t.month, t.day, hour, min, 0, "+10:00")
          temp = row.xpath("./td[contains(@headers, '#{tid}-temp')]").text.to_f
          rain = row.xpath("./td[contains(@headers, '#{tid}-rainsince9am')]").text.to_f
          wind_speed = row.xpath("./td[contains(@headers, '#{tid}-wind-spd-kph')]").text.to_f
          wind_dir_name = row.xpath("./td[contains(@headers, '#{tid}-wind-dir')]").text
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

  task :reverse_geocoding => :environment do
    locations = Location.where(loc_type: "station", state: "vic")
    locations.each do |loc|
      if loc.postcode == nil
        lat = loc.lat
        lon = loc.lon
        url = "#{GOOGLE_BASE_URL}#{lat},#{lon}&key=#{GOOGLE_API_KEY}"
        results = JSON.parse(open(url).read)['results'][0]['address_components']
        results.each do |comp| 
          if comp['types']==["postal_code"]
            postcode = comp['long_name']
            post = Postcode.find_or_initialize_by(postcode: postcode)
            loc.postcode = post
            loc.save
            post.save if post.changed?
          end
        end
      end
    end
  end

  task :init_postcode => :environment do
    filename = './lib/assets/vic_post.csv'
    input = CSV.read(filename)
    array = []
    input.each{|line| array << {"postcode"=>line[0],"loc_id"=>line[1].gsub(/\s+/,""),"lat"=>line[2],"lon"=>line[3]} }
    array.each do |line|
      post = Postcode.find_or_initialize_by(postcode: line['postcode'].to_i)
      location = post.locations.find_or_initialize_by(loc_id: line['loc_id'], loc_type: "region", state: "vic")
      location.lat = line['lat']
      location.lon = line['lon']
      location.active = false
      location.save if location.changed?
      post.save if post.changed?
    end
  end

  task :get_history => :environment do
    # # Get the list of locations from BOM.
    # index = load_bom_index
    # index.each do |info_table|
    #   info_table['node'].xpath("./tbody/tr/th/a").each do |location_node|
    #     # Find the location's information
    #     location_doc = Nokogiri.HTML(open("#{BOM_BASE_URL}#{location_node.attr :href}"))

    #   end
    # end
  end
end
