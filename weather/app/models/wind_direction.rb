class WindDirection < ActiveRecord::Base
	belongs_to :measurement

	def direction
			degree = self.bearing
			return '' unless not degree.nil?
			if degree > 348.75 or degree <= 11.25
				wind_direction = 'N'
			elsif degree.between?(11.25, 33.75)
				wind_direction = 'NNE'
			elsif degree.between?(33.75, 56.25)
				wind_direction = 'NE'
			elsif degree.between?(56.25, 78.75)
				wind_direction = 'ENE'
			elsif degree.between?(78.75, 101.25)
				wind_direction = 'E'
			elsif degree.between?(101.25, 123.75)
				wind_direction = 'ESE'
			elsif degree.between?(123.75, 146.25)
				wind_direction = 'SE'
			elsif degree.between?(146.25, 168.75)
				wind_direction = 'SSE'
			elsif degree.between?(168.75, 191.25)
				wind_direction = 'S'
			elsif degree.between?(191.25, 213.75)
				wind_direction = 'SSW'
			elsif degree.between?(213.75, 236.25)
				wind_direction = 'SW'
			elsif degree.between?(236.25, 258.75)
				wind_direction = 'WSW'
			elsif degree.between?(258.75, 281.25)
				wind_direction = 'W'
			elsif degree.between?(281.25, 303.75)
				wind_direction = 'WNW'
			elsif degree.between?(303.75, 326.25)
				wind_direction = 'NW'
			elsif degree.between?(326.25, 348.75)
				wind_direction = 'NNW'
			end
			return wind_direction
	end
end
