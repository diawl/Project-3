class Location < ActiveRecord::Base
	has_many :wdates
	belongs_to :postcode

	def lat_lon
		return {"lat"=>self.lat,"lon"=>self.lon}
	end
	
	def last_update
	end

	def find_weather(date)
	end

	def getCurrent
	end

	def getData(date)
	end

	def getPrediction(period)
	end
end
