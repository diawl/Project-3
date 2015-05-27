# require 'nokogiri'
# require 'open-uri'

# # Define the URL we are opening
# URL = 'http://www.postcodes-australia.com/state-postcodes/vic'
# doc = Nokogiri::HTML(open(URL))

# rows = doc.css('div#container div#content ul.pclist li')
# THREADS = 50 # 32s
# threads = []

# def get_loc(rows, start, finish=99999999999)
#   (start..finish).each { |x|
#     begin
#       row = rows[x]

#       if not row.nil?
#         postcode_id = row.css('a').text.to_i
#         url = row.css('a')[0]['href'].to_s
#         arr = ''
#         if row.css('li').size > 1
#           row.css('li').each do |text|
#             arr = arr + ', ' + text
#           end
#           arr = arr[2, arr.size()]
#         else
#           arr = row.css('li').text
#         end

#         postcode_name = arr
#         doc_station = Nokogiri::HTML(open(url))
#         coordinates = doc_station.css('div#container div#content p')
#         if coordinates[0].text.include? 'Latitude'
#           latitude = coordinates[0].text.split(':')[1].to_f
#           longitude = coordinates[1].text.split(':')[1].to_f
#         else
#           latitude = coordinates[1].text.split(':')[1].to_f
#           longitude = coordinates[2].text.split(':')[1].to_f
#         end
#         if not latitude == 0.0
#           new_postcode = Postcode.new(:name => postcode_name, :postcode => postcode_id, :latitude => latitude, :longitude => longitude)
#           new_postcode.save
#           # puts 'postcode: ' + postcode_name + ' ' + postcode_id.to_s + ' lat: ' + latitude.to_s + ' long: ' + longitude.to_s
#         end
#       end
#     rescue
#       # puts "row: #{row}"
#     end
#   }
# end

# start = 0
# step = rows.count / THREADS
# end1 = step
# # time_0 = Time.new
# 1.upto(THREADS) do |num|
#   threads[num]=Thread.new { get_loc(rows, start, end1)}
#   sleep(0.1)
#   start = end1 + 1
#   end1 += step
# end

# 1.upto(THREADS) do |num|
#   threads[num].join
# end
# # puts 'time: ' + (Time.new - time_0).to_s