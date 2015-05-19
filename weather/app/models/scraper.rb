class Scrapper
	URL = 'http://www.bom.gov.au/vic/observations/melbourne.shtml'
	# store 4 API_KEYs
	BASE_URL = 'https://api.forecast.io/forecast'
	KEY_POOL = ['670f1423abb918843ea20f398497c640','aeb0292dc5ba3440ea9ed2f08776b7be','88f3aa9aa37261cd23c9e3cedd12ac3a','bb90b0dd959b17412953005da39b4523']
	seed = 0

	# method to get a API_KEY from the pool
	def choose_key(seed, pool)
		if seed >= (pool.size-1) || seed < 0
			return {'seed' => 0, 'key' => pool[0]}
		else
			return {'seed' => seed+1, 'key' => pool[seed]}
		end
	end

	# method to parse particular html pages to get lon & lat of every station
	def get_loc(url)
		page = Nokogiri::HTML(open(url))
		return {'lat' => page.css("table[class='stationdetails'] td")[3].text[6,7].to_f,
		'lon' => page.css("table[class='stationdetails'] td")[4].text[6,7].to_f}
	end

	# method to trans dd/hh:mma(p)m to DateTime
	def get_datetime(time)
		reg = /([0-9]{1,2})\/([0-9]{1,2}):([0-9]{1,2})([ap]m)/.match(time).to_a
		# day
		dd = reg.to_a[1]
		# hour
		hh = reg.to_a[2]
		# minute
		mm = reg.to_a[3]
		# puts mm.class
		time_flag = reg.to_a[4]
		if time_flag=='pm' && hh != '12'
			hh=(hh.to_i+12).to_s
		end
		if time_flag=='am' && hh == '12'
			hh='00'
		end
		return DateTime.new(Time.now.year, Time.now.month, dd.to_i, hh.to_i, mm.to_i, 0, "+10:00")
	end

	# method: 1 for newest data
	#         2 for history data
	def scrape_bom(url, method)
		result = Array.new 
		case method
		when 1
			page = Nokogiri::HTML(open(url))
			page.css("tr[class='rowleftcolumn']").each do |line|
				elem = Hash.new
				name = line.css("th").text
				time = get_datetime(line.css("td")[0].text)	
				href = 'http://www.bom.gov.au' + line.css("th a")[0]['href']			
				temp = line.css("td")[1].text.to_f
				dew_point = line.css("td")[3].text.to_f
				wind_dir = line.css("td")[6].text
				wind_spd = line.css("td")[7].text.to_i
				rain_since_nine = line.css("td")[12].text.to_f
				elem.store("name",name)
				elem.store("time",time)
				elem.store("href",href)
				elem.store("temp",temp)
				elem.store("dew_point",dew_point)
				elem.store("wind_dir",wind_dir)
				elem.store("wind_spd",wind_spd)
				result << elem
			end	
			return result
		when 2
			page = Nokogiri::HTML(open(url))
			page.css("tr[class='rowleftcolumn']").each do |line|
				elem = Hash.new
				time = get_datetime(line.css("td")[0].text)				
				temp = line.css("td")[1].text.to_f
				dew_point = line.css("td")[3].text.to_f
				wind_dir = line.css("td")[6].text
				wind_spd = line.css("td")[7].text.to_i
				rain_since_nine = line.css("td")[13].text.to_f
				elem.store("time",time)
				elem.store("temp",temp)
				elem.store("dew_point",dew_point)
				elem.store("wind_dir",wind_dir)
				elem.store("wind_spd",wind_spd)
				result << elem
			end
			return result
		else
			return nil
		end
	end

	# update database from bom
	def updateDB(url_b)
		res_array = scrape_bom(url_b,1)
		res_array.each do |hash|
			if Location.find_by(loc_id: hash['name']) 
				@location = Location.find_by(loc_id: hash['name'])
			else
				loc = get_loc(hash['href'])
				@location = Location.new(lon: loc['lon'],lat: loc['lat'],loc_id: hash['name'])
				@location.save
			end

			if @location.wdates.find_by(date: hash['time'])
				@date = @location.wdates.find_by(date: hash['time'])
			else
				@date = @location.wdates.new(date: hash['time'])
			end

			# create bureau records for specific datetime if NTFD
			if @date.bureau == nil 
				update_bom_by_date(@date, hash)
			end
		end
	end

	def initDB(url_b)
		# initially check & update db
		res_array = scrape_bom(url_b,1)
		res_array.each do |hash|
			res = scrape_bom(hash['href'],2)
			if Location.find_by(loc_id: hash['name']) 
				@location = Location.find_by(loc_id: hash['name'])
			else
				loc = get_loc(hash['href'])
				@location = Location.new(lon: loc['lon'],lat: loc['lat'],loc_id: hash['name'])
				@location.save
			end
			res.each do |h| 
				if @location.wdates.find_by(date: h['time'])
					@date = @location.wdates.find_by(date: h['time'])
				else
					@date = @location.wdates.new(date: h['time'])
				end
				# create BOM measurement for specific time if NTFD
				if @date.bureau == nil 
					update_bom_by_date(@date, h)
				end
			end
		end
	end
end